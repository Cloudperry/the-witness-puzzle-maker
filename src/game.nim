import std/[strformat, options]
import cligen, nimraylib_now
import levels, levelGfx, geometry

when defined(windows):
  {.passL: "-static".} # Use static linking on Windows

const fontSize = 30

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

proc game(levels: seq[string]) =
  # Init
  var
    screenWidth = 1280
    screenHeight = 720
    levelName: string
    level: Level
    drawOptions: DrawOptions 
    drawableLevel: DrawableLevel
    playingLevel: bool
    currentPointStr: string
    playerLine: Line
  
  proc loadLevel() =
    level = loadLevelFromFile(levelName)
    drawOptions = DrawOptions()
    drawOptions.setPositionDefaults((screenWidth, screenHeight))
    drawableLevel = level.getDrawableLevel(drawOptions)
    playingLevel = true

  setConfigFlags(MSAA_4X_HINT)
  setConfigFlags(FULLSCREEN_MODE)
  initWindow(screenWidth, screenHeight, "The Witness")
  let monitor = getCurrentMonitor()
  screenWidth = getMonitorWidth(monitor)
  screenHeight = getMonitorHeight(monitor)
  setTargetFPS(getMonitorRefreshRate(monitor))

  if levels.len > 0:
    levelName = levels[0]
    loadLevel()

  while not windowShouldClose(): # Main loop
    # Update
    if not playingLevel:
      if doTextEntry(levelName):
        loadLevel()
    else:
      if doTextEntry(currentPointStr):
        let point = currentPointStr.parsePoint()
        if point.isSome:
          playerLine &= point.get
          currentPointStr.setLen(0)

    # Draw
    beginDrawing()
    clearBackground(Darkgray)
    if playingLevel:
      # Draw text
      let textOffsetY = drawableLevel.mazeDistToScreen(
        dist(level.topLeftCorner.y, drawableLevel.topLeft.y) / 2, drawOptions
      )
      let textTop = fmt"playing {levelName}"
      let textTopWidth = measureText(textTop.cstring, fontSize)
      drawText(textTop.cstring, screenWidth div 2 - textTopWidth div 2, textOffsetY, fontSize, Raywhite)
      let textBot = fmt"enter a new point: {currentPointStr}"
      let textBotWidth = measureText(textBot.cstring, fontSize)
      drawText(textBot.cstring, screenWidth div 2 - textBotWidth div 2, screenHeight - textOffsetY, fontSize, Raywhite)
      # Draw level
      level.draw(drawableLevel.gfxData, drawOptions)
      if playerLine.len > 0:
        level.drawPlayerLine(playerLine, drawableLevel, drawOptions)
    else:
      let text = fmt"Type level name to play and press ENTER: {levelName}" 
      let textWidth = measureText(text.cstring, fontSize)
      # Text is not vertically centered, because using measureTextEx was giving me segfaults
      drawText(text.cstring, screenWidth div 2 - textWidth div 2, 
               screenHeight div 2, fontSize, Raywhite) 
    endDrawing()

  closeWindow()

dispatch game # Automatically generate a CLI that can be used to open a level to play
