import std/strformat
import cligen, nimraylib_now
import levels, levelGfx

when defined(windows):
  {.passL: "-static".} # Use static linking on Windows

proc editor(levels: seq[string]) =
  # Init
  var
    screenWidth = 1200'i32
    screenHeight = 750'i32
    levelName: string
    level: Level
    drawOptions: DrawOptions 
    levelGfxData: LevelGfxData
    drawCoordSpace: DrawCoordSpace
    editingLevel: bool
  
  proc loadLevel() =
    level = loadLevelFromFile(levelName)
    drawOptions = initDrawOptions((screenWidth.int, screenHeight.int))
    drawCoordSpace = level.getDrawCoordSpace()
    levelGfxData = level.calcGfxData(drawCoordSpace, drawOptions)
    editingLevel = true

  setConfigFlags(MSAA_4X_HINT)
  setConfigFlags(FULLSCREEN_MODE)
  initWindow(screenWidth, screenHeight, "The Witness puzzle editor")
  let monitor = getCurrentMonitor()
  screenWidth = getMonitorWidth(monitor)
  screenHeight = getMonitorHeight(monitor)
  setTargetFPS(144)

  if levels.len > 0:
    levelName = levels[0]
    loadLevel()

  while not windowShouldClose(): # Main loop
    # Update
    if not editingLevel:
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
    if editingLevel:
      drawText(fmt"Loaded level {levelName}", 300, 100, 20, Raywhite)
      level.draw(levelGfxData)
    else:
      drawText(fmt"Type level name to edit and press ENTER: " & levelName, 300, 350, 20, Raywhite)
    endDrawing()

  closeWindow()

dispatch editor # Automatically generate a CLI that can be used to open one or more levels for editing
