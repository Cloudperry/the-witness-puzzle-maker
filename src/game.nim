import std/strformat
import cligen, nimraylib_now
import levels, levelGfx

when defined(windows):
  {.passL: "-static".} # Use static linking on Windows

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
      var key = getCharPressed()
      while key in 32 .. 125:
        levelName &= key.char
        key = getCharPressed()
      if isKeyPressed(BACKSPACE) and levelName.len > 0:
        levelName.setLen(levelName.len - 1)
      elif isKeyPressed(ENTER) and levelName.len > 0:
        loadLevel()

    # Draw
    beginDrawing()
    clearBackground(Darkgray)
    if playingLevel:
      drawText(fmt"Loaded level {levelName}", 300, 100, 20, Raywhite)
      level.draw(drawableLevel.gfxData, drawOptions)
    else:
      drawText(fmt"Type level name to play and press ENTER: " & levelName, 300, 350, 20, Raywhite)
    endDrawing()

  closeWindow()

dispatch game # Automatically generate a CLI that can be used to open a level to play
