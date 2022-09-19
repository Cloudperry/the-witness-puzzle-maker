import strformat
import cligen, frosty, nimraylib_now

proc game(level: seq[string]) =
  var screenWidth = 1200'i32
  var screenHeight = 750'i32
  initWindow(screenWidth, screenHeight, "The Witness puzzles clone game")
  setTargetFPS(144)

  while not windowShouldClose():
    beginDrawing()
    clearBackground(Darkgray)
    if level.len == 0:
      drawText("Here the game will display a level select screen which shows the levels in ./levels", 200, 350, 20, Raywhite)
    else:
      drawText(fmt"Here the game will open the level with filename {level[0]}", 250, 350, 20, Raywhite)
    endDrawing()

  closeWindow()

dispatch game # Automatically generate a CLI that can be used to choose a level to play
