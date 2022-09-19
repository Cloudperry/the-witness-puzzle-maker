import strformat
import cligen, frosty, nimraylib_now

proc editor(levels: seq[string]) =
  var screenWidth = 1200'i32
  var screenHeight = 750'i32
  initWindow(screenWidth, screenHeight, "The Witness puzzle editor")
  setTargetFPS(144)

  while not windowShouldClose():
    beginDrawing()
    clearBackground(Darkgray)
    if levels.len == 0:
      drawText("Here the editor will ask for a level filename to edit", 300, 350, 20, Raywhite)
    else:
      drawText(fmt"""Here the editor will open the following levels in different tabs: {levels.join(", ")}""", 200, 350, 20, Raywhite)
    endDrawing()

  closeWindow()

dispatch editor # Automatically generate a CLI that can be used to open one or more levels for editing
