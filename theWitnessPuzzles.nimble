# Package
version = "0.1.0"
author = "Roni Hokkanen"
description = "A 2D clone of the maze puzzles seen in The Witness. Includes an editor and the game itself."
srcDir = "src"
namedBin["game"] = "witness-clone"
backend = "c"
license = "MIT"

# Dependencies
requires "nim >= 1.7.3"
requires "cligen == 1.5.28"
requires "nimraylib_now == 0.15.0"
requires "https://github.com/disruptek/frosty == 3.0.0"

task gendocs, "Generate source code documentation using the Nim documentation generator":
  exec "nim doc --project --index:on --outdir:docs/generated src/game.nim"

task gencoverage, "Generate coverage using coco":
  exec "coco -t='tests/*.nim' --cov='!tests' --compiler='--hints:off'"
  exec "rm -rf docs/coverage/"
  exec "mv coverage docs/"
  exec "mv lcov.info docs/coverage/"
  exec "rm -rf nimcache"

task genlevel, "Generate level file from program":
  exec "cd levels; nim r " & commandLineParams[^1]

task regenlevels, "Generate level files from all programs under levels/":
  exec """cd levels
    for filename in *.nim; do
      # Using unsafe release build without optimizations for fast build times
      nim r -d:danger --opt:none $filename 
    done
  """
