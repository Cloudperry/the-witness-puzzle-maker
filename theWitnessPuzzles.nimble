# Package
version     = "0.1.0"
author      = "Roni Hokkanen"
description = "."
srcDir      = "src"
bin         = @["editor", "game"]
backend     = "c"

# Dependencies
requires "nim == 1.7.1"
requires "cligen == 1.5.28"
requires "nimraylib_now == 0.15.0"
requires "https://github.com/disruptek/frosty == 3.0.0"

