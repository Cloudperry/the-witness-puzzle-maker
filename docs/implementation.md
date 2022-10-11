# Structure of the program
- The project consists of two main programs
  - editor.nim
    - An editor for the maze puzzles
  - game.nim
    - The game itself. It opens the level files that the editor saves.
- The programs use the following libraries
  - graphs.nim
    - Implements a generic graph data structure using adjacency lists. There are also some basic vector operations and 2D grid related functions (I will move these to another module). 
  - levels.nim 
    - Implements the level format (data structure) and saving the levels to disk. Some level editing primitives will also be added to this module.
  - levelGfx.nim
    - Implements a coordinate transformation from the level coordinates (floats) to pixel coordinates for drawing (integers). Handles drawing of the levels.