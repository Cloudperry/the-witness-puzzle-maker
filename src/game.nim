import std/[strformat, strutils, options, tables, sets, monotimes, times, os]
import cligen, nimraylib_now
import levels, levelGfx, geometry, graphs

when defined(windows):
  {.passL: "-static".} # Use static linking on Windows

const 
  fontSize = 30
  textFlashDuration = 2000
  moveRepeatDuration = 400

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

proc game(startingLine = "", levels: seq[string]) =
  # Game state could be moved into an object. That would make for example
  # unloading the level extremely simple.
  # Init
  var 
    # The CLI generator I use didn't like vars in the proc parameters.
    # Below is a workaround for that.
    levels = levels
    screenWidth = 1280
    screenHeight = 720
    selectedLevel: int
    levelName: string
    level: Level
    drawOptions: DrawOptions 
    drawableLevel: DrawableLevel
    playingLevel: bool
    currentPointStr: string
    playerLine: Line
    currentTime, prevTime: MonoTime
    textFlashTimer, deltaTime: int64
    lastPointAdd: PointAddResult
  
  proc unloadLevel() =
    level = Level()
    drawOptions = DrawOptions()
    drawableLevel = DrawableLevel()
    playingLevel = false
    lastPointAdd = None
    playerLine.setLen 0

  proc loadLevel() =
    level = loadLevelFromFile(levelName)
    drawOptions = DrawOptions()
    drawOptions.setPositionDefaults((screenWidth, screenHeight))
    drawableLevel = level.getDrawableLevel(drawOptions)
    playingLevel = true

  proc addPoint(point: Option[Point2D]) =
    if point.isSome:
      let point = point.get
      lastPointAdd = playerLine.checkAndAddPoint(point, level)
      if lastPointAdd == Invalid:
        textFlashTimer += deltaTime
      currentPointStr.setLen 0

  setConfigFlags(MSAA_4X_HINT)
  setConfigFlags(FULLSCREEN_MODE)
  initWindow(screenWidth, screenHeight, "The Witness")
  let monitor = getCurrentMonitor()
  screenWidth = getMonitorWidth(monitor)
  screenHeight = getMonitorHeight(monitor)
  let refreshRate = getMonitorRefreshRate(monitor)
  setTargetFPS(refreshRate)
  echo fmt"Set window to {screenWidth}x{screenHeight}@{refreshRate}hz"

  if levels.len > 0:
    levelName = levels[0]
    if levels.len == 1:
      loadLevel()
  else:
    for filename in walkPattern("levels/*.bin"):
      levels.add filename
  if startingLine.len > 0:
    for pointStr in startingLine.split(','):
      addPoint pointStr.parsePoint()

  while not windowShouldClose(): # Main loop
    prevTime = currentTime
    currentTime = getMonoTime()
    deltaTime = inMilliseconds(currentTime - prevTime)
    # Make timer handling library code if any more timers are added
    if textFlashTimer >= textFlashDuration:
      textFlashTimer = 0
    elif textFlashTimer > 0:
      textFlashTimer += deltaTime
    # Update
    if not playingLevel:
      if levels.len == 0:
        if doTextEntry(levelName):
          loadLevel()
      else:
        levelName = levels[selectedLevel]
        if isKeyPressed(KeyboardKey.LEFT):
          if selectedLevel > 0:
            dec selectedLevel
        elif isKeyPressed(KeyboardKey.RIGHT):
          if selectedLevel < levels.high:
            inc selectedLevel
        elif isKeyPressed(ENTER):
          loadLevel()
    else:
      if lastPointAdd notin {CorrectSolution, IncorrectSolution}:
        if isKeyDown(C):
          playerLine.setLen(0)
        elif isKeyPressed(KeyboardKey.LEFT):
          addPoint playerLine.pointInDirection((-1.0, 0.0), level)
        elif isKeyPressed(KeyboardKey.RIGHT):
          addPoint playerLine.pointInDirection((1.0, 0.0), level)
        elif isKeyPressed(DOWN):
          addPoint playerLine.pointInDirection((0.0, 1.0), level)
        elif isKeyPressed(UP):
          addPoint playerLine.pointInDirection((0.0, -1.0), level)
        elif doTextEntry(currentPointStr):
          addPoint currentPointStr.parsePoint()
      else:
        if isKeyPressed(R):
          lastPointAdd = None
          playerLine.setLen(0)
        elif isKeyPressed(S):
          unloadLevel()
        elif isKeyPressed(P):
          echo playerLine

    # Draw
    beginDrawing()

    clearBackground(Darkgray)
    if not playingLevel:
      if levels.len > 0:
        let padding = screenWidth div 80
        var currWidth = padding
        for i, level in levels:
          var text = fmt"""{levels[i].replace("levels/")}"""
          if i == selectedLevel: 
            text = '[' & text & ']'
          drawText(text.cstring, currWidth, screenHeight div 2, fontSize, Raywhite) 
          currWidth += measureText(text.cstring, fontSize) + padding
      else:
        let text = fmt"Type level path to play and press ENTER: {levelName}" 
        let textWidth = measureText(text.cstring, fontSize)
        # Text is not vertically centered, because using measureTextEx was giving me segfaults
        drawText(text.cstring, screenWidth div 2 - textWidth div 2, 
                 screenHeight div 2, fontSize, Raywhite) 
    else:
      # Draw text
      let textOffsetY = drawableLevel.mazeDistToScreen(
        dist(level.topLeftCorner.y, drawableLevel.topLeft.y) / 2, drawOptions
      )
      let textTop = fmt"playing {levelName}"
      let textTopWidth = measureText(textTop.cstring, fontSize)
      drawText(textTop.cstring, screenWidth div 2 - textTopWidth div 2, textOffsetY, fontSize, Raywhite)
      var textBot: string
      if lastPointAdd in {None, Valid, Invalid}:
        textBot = fmt"Enter a new point (or press C to clear line): {currentPointStr}"
        if textFlashTimer > 0:
          textBot = "Invalid point."
          if playerLine.len == 0:
            textBot &= fmt" The first point of a line has to be one of the starting points (big circles)."
          else:
            textBot &= fmt" The point needs to be next to your previous point and it can't cross your line."
      elif lastPointAdd == CorrectSolution:
        textBot = "You have solved the level. Press esc to quit, s to select another level or r to restart the level."
      elif lastPointAdd == IncorrectSolution:
        textBot = "Your line goes from start to end, but the solution is incorrect. Press esc to quit, s to select another level or r to restart the level."
      let textBotWidth = measureText(textBot.cstring, fontSize)
      drawText(textBot.cstring, screenWidth div 2 - textBotWidth div 2, screenHeight - textOffsetY, fontSize, Raywhite)
      # Draw level
      level.draw(drawableLevel.gfxData, drawOptions)
      if playerLine.len > 0:
        level.drawPlayerLine(playerLine, drawableLevel, drawOptions)

    endDrawing()

  closeWindow()

dispatch game # Automatically generate a CLI that can be used to open a level to play
