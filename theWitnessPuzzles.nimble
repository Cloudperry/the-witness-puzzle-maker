# Package
version = "0.1.0"
author = "Roni Hokkanen"
description = "A 2D clone of the maze puzzles seen in The Witness. Includes an editor and the game itself."
srcDir = "src"
namedBin["game"] = "witness-clone"
namedBin["editor"] = "witness-clone-editor"
backend = "c"
license = "MIT"

# Dependencies
requires "nim >= 1.7.1"
requires "cligen == 1.5.28"
requires "nimraylib_now == 0.15.0"
requires "https://github.com/disruptek/frosty == 3.0.0"
