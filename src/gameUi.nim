import std/[strformat, strutils, sequtils, options, tables, sets, monotimes, times, os]
import cligen, nimraylib_now
import game, levelGfx, geometry

when defined(windows):
  {.passL: "-static".} # Use static linking on Windows

const 
  fontSize = 30
  textFlashDuration = 2000

type
  Window = object
    width = 3840
    height = 2160

  UiState = object
    levels: seq[string]
    selectedLvl: int
    drawOptions: DrawOptions 
    drawableLevel: DrawableLevel
    playingLevel: bool
    currentPointStr: string
    textFlashTimer: int64

proc loadLevel(ui: var UiState, game: var GameState, win: Window) =
  game.init(ui.levels[ui.selectedLvl])
  ui.drawOptions = DrawOptions()
  ui.drawOptions.setPositionDefaults((win.width, win.height))
  ui.drawableLevel = game.level.getDrawableLevel(ui.drawOptions)
  ui.playingLevel = true

proc addPoint(ui: var UiState, game: var GameState, point: Point2D) =
  game.addPointAndCheckResult(point)
  ui.currentPointStr.setLen 0

proc init(ui: var UiState, game: var GameState, win: Window, 
          levels: seq[string], startingLine = "") =
  ui = UiState()
  ui.levels = levels
  if ui.levels.len == 1:
    ui.loadLevel(game, win)
    if startingLine.len > 0:
      let startingLineNoWhitespace = startingLine.multiReplace((" ", ""), ("\n", ""))
      for pointStr in startingLineNoWhitespace.split("->"):
        let point = pointStr.parsePoint
        if point.isSome:
          ui.addPoint(game, point.get)
        else:
          echo "Invalid point in line {startingLine}. The format used by this line parser is used in tests/tlevelsolutions.nim for example."
          
  else:
    for filename in walkPattern("levels/*.bin"):
      ui.levels.add filename

proc getChoiceStr[T](list: openArray[T]): string =
  for i, element in list:
    result.add fmt"{i+1}={element}"
    if i == list.high - 1:
      result.add " or "
    elif i != list.high: 
      result.add ' '

proc doTextEntry(text: var string): bool =
  var key = getCharPressed()
  while key in 32 .. 125:
    text &= key.char
    key = getCharPressed()
  if isKeyPressed(BACKSPACE) and text.len > 0:
    text.setLen(text.len - 1)
  elif isKeyPressed(DELETE) and text.len > 0:
    text.setLen(0)
  elif isKeyPressed(ENTER) and text.len > 0:
    return true

proc update(ui: var UiState, game: var GameState, win: Window, deltaTime: int64) =
  # Make timer handling into functions if any more timers are added
  if ui.textFlashTimer >= textFlashDuration:
    ui.textFlashTimer = 0
  elif ui.textFlashTimer > 0:
    ui.textFlashTimer += deltaTime
  # Update
  if not ui.playingLevel:
    if ui.levels.len == 0:
      if doTextEntry(ui.levels[0]):
        ui.loadLevel(game, win)
    else:
      if isKeyPressed(KeyboardKey.LEFT):
        if ui.selectedLvl > 0:
          dec ui.selectedLvl
      elif isKeyPressed(KeyboardKey.RIGHT):
        if ui.selectedLvl < ui.levels.high:
          inc ui.selectedLvl
      elif isKeyPressed(ENTER):
        ui.loadLevel(game, win)
  else:
    if game.status notin {CorrectSolution, IncorrectSolution}:
      var nextMove: Option[Point2D]
      if isKeyDown(C):
        game.init(ui.levels[ui.selectedLvl])
      elif isKeyPressed(KeyboardKey.LEFT):
        nextMove = game.neighborInDirection((-1.0, 0.0))
      elif isKeyPressed(KeyboardKey.RIGHT):
        nextMove = game.neighborInDirection((1.0, 0.0))
      elif isKeyPressed(DOWN):
        nextMove = game.neighborInDirection((0.0, 1.0))
      elif isKeyPressed(UP):
        nextMove = game.neighborInDirection((0.0, -1.0))
      elif doTextEntry(ui.currentPointStr):
        try:
          let selected = ui.currentPointStr.parseInt()
          nextMove = some game.nxtMovesChoice[selected - 1]
        except:
          ui.textFlashTimer += deltaTime
          ui.currentPointStr.setLen 0
      if nextMove.isSome:
        ui.addPoint(game, nextMove.get)
    else:
      if isKeyPressed(R):
        game.init(ui.levels[ui.selectedLvl])
      elif isKeyPressed(S):
        ui.init(game, win, @[])
      elif isKeyPressed(P):
        echo fmt"Level {ui.levels[ui.selectedLvl]} {game.status}: {game.line}"

proc draw(ui: var UiState, game: var GameState, win: Window) =
  proc removeExtAndDir(s: string): string =
    s.multiReplace(("levels/", ""), (".bin", ""))
  clearBackground(Darkgray)
  let levelName = ui.levels[ui.selectedLvl].removeExtAndDir()
  if not ui.playingLevel:
    if ui.levels.len > 0:
      let padding = win.height div 40
      var texts: seq[string]
      var xAndW: seq[tuple[x, w: int]] = @[(0, 0)]
      for i, level in ui.levels:
        texts.add fmt"""{ui.levels[i].removeExtAndDir()}"""
        if i == ui.selectedLvl: 
          texts[^1] = '[' & texts[^1] & ']'
        let width = measureText(texts[^1].cstring, fontSize).int
        xAndW.add (
          xAndW[^1].x + xAndW[^1].w + padding, width
        )
      if xAndW[ui.selectedLvl+1].x + xAndW[ui.selectedLvl+1].w > win.width:
        xAndW.applyIt( # FIX THIS MESS
          (it.x - (padding + xAndW[ui.selectedLvl+1].x + xAndW[ui.selectedLvl+1].w - win.width), it.w)
        )
      for i, text in texts:
        drawText(text.cstring, xAndW[i+1].x, win.height div 2, fontSize, Raywhite) 
    else:
      let text = fmt"Type level path to play and press ENTER: {levelName}" 
      let textWidth = measureText(text.cstring, fontSize)
      drawText(text.cstring, win.width div 2 - textWidth div 2, 
               win.height div 2, fontSize, Raywhite) 
  else:
    let textOffsetY = ui.drawableLevel.mazeDistToScreen(
      dist(game.level.topLeftCorner.y, ui.drawableLevel.topLeft.y) / 2, ui.drawOptions
    )
    let textTop = fmt"playing {levelName}"
    let textTopWidth = measureText(textTop.cstring, fontSize)
    drawText(textTop.cstring, win.width div 2 - textTopWidth div 2,
             textOffsetY, fontSize, Raywhite)
    let textBot =
      if ui.textFlashTimer > 0:
        "Invalid point. Please enter a number that corresponds to the points listed."
      elif game.status == None:
        "Choose one of the points by entering a number" &
        fmt" {getChoiceStr(game.nxtMovesChoice)}: {ui.currentPointStr}"
      elif game.status == HasDiagNeighbors:
        fmt"Move with arrow keys or choose {getChoiceStr(game.nxtMovesChoice)}:" &
        fmt" {ui.currentPointStr} (C to clear line)"
      elif game.status == OnlyGridNeighbors:
        fmt"Use arrow keys to move. (C to clear line)"
      elif game.status == CorrectSolution:
        "You have solved the level. Press esc to quit, s to select another" &
        " level or r to restart the level."
      elif game.status == IncorrectSolution:
        "Your line goes from start to end, but the solution is incorrect." &
        " Press esc to quit, s to select another level or r to restart the level."
      else:
        ""
    let textBotWidth = measureText(textBot.cstring, fontSize)
    drawText(textBot.cstring, win.width div 2 - textBotWidth div 2,
             win.height - textOffsetY, fontSize, Raywhite)
    # Draw level
    game.level.draw(ui.drawableLevel.gfxData, ui.drawOptions)
    if game.line.len > 0:
      game.line.drawPlayerLine(game.level, ui.drawableLevel, ui.drawOptions)

proc gameUi(startingLine = "", levels: seq[string]) =
  # Init
  var 
    win: Window
    ui: UiState
    game: GameState
    prevTime, currentTime: MonoTime

  setConfigFlags(MSAA_4X_HINT)
  setConfigFlags(FULLSCREEN_MODE)
  initWindow(win.width, win.height, "The Witness clone")
  let monitor = getCurrentMonitor()
  win.width = getMonitorWidth(monitor)
  win.height = getMonitorHeight(monitor)
  let refreshRate = getMonitorRefreshRate(monitor)
  setTargetFPS(refreshRate)
  echo fmt"Set window to {win.width}x{win.height}@{refreshRate}hz"
  ui.init(game, win, levels, startingLine)

  while not windowShouldClose(): # Main loop
    prevTime = currentTime
    currentTime = getMonoTime()
    let deltaTime = inMilliseconds(currentTime - prevTime)
    update(ui, game, win, deltaTime)
    beginDrawing()
    draw(ui, game, win)
    endDrawing()

  closeWindow()

dispatch gameUi # Automatically generate a CLI that can be used to open a level to play
