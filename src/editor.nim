import strformat
import cligen, nimraylib_now
import levels

proc editor(levels: seq[string]) =
  # Init
  var
    screenWidth = 1200'i32
    screenHeight = 750'i32
    levelName: string
    level: Level
    editingLevel: bool
  if levels.len > 0:
    levelName = levels[0]
    editingLevel = true
    level = loadLevelFromFile(levelName)
  initWindow(screenWidth, screenHeight, "The Witness puzzle editor")
  setTargetFPS(144)

  while not windowShouldClose(): # Main loop
    # Update
    if not editingLevel:
      var key = getCharPressed()
      while key in 32 .. 125:
        levelName &= key.char
        key = getCharPressed()
      if isKeyPressed(BACKSPACE) and levelName.len >= 1:
        levelName.setLen(levelName.len - 1)
      elif isKeyPressed(ENTER):
        editingLevel = true
        level = loadLevelFromFile(levelName)

    # Draw
    beginDrawing()
    clearBackground(Darkgray)
    if editingLevel:
      drawText(fmt"Loaded level {levelName}", 200, 350, 20, Raywhite)
    else:
      drawText(fmt"Type level name to edit and press ENTER: " & levelName, 300, 350, 20, Raywhite)
    endDrawing()

  closeWindow()

dispatch editor # Automatically generate a CLI that can be used to open one or more levels for editing
