# Package
version = "0.1.0"
author = "Roni Hokkanen"
description = "A 2D clone of the maze puzzles seen in The Witness. Includes a library for creating levels and the game itself."
srcDir = "src"
namedBin["gameUi"] = "witness-clone"
backend = "c"
license = "MIT"

# Dependencies
requires "nim >= 1.7.3"
requires "cligen >= 1.5.28"
requires "naylib >= 4.6.2"
requires "https://github.com/disruptek/frosty == 3.0.0"

task gendocs, "Generate source code documentation using the Nim documentation generator":
  when defined(posix):
    exec "nim doc --project --index:on --outdir:docs/generated src/game.nim"
  when defined(windows):
    exec r"nim doc --project --index:on --outdir:docs\generated src\game.nim"

task gencoverage, "Generate coverage using coco":
  when defined(posix):
    exec "coco -t='tests/*.nim' --cov='!tests' --compiler='--hints:off'"
    exec "rm -rf docs/coverage/"
    exec "mv coverage docs/"
    exec "mv lcov.info docs/coverage/"
    exec "rm -rf nimcache"
  when defined(windows):
    exec "echo This command is implemented using Bash specific shell commands. Tests work on Windows, but generating coverage doesn't."

task genlevel, "Generate level file from program":
  when defined(posix):
    exec "cd levels; nim --hints:off r " & commandLineParams[^1]
  when defined(windows):
    exec "cd /d levels; nim --hints:off r " & commandLineParams[^1]

task regenlevels, "Generate level files from all programs under levels directory":
  when defined(posix):
    exec """cd levels
      for filename in *.nim; do
        echo generating levels inside ${filename}...
        # Using unsafe release build without optimizations for fast build times
        nim --hints:off r -d:danger --opt:none $filename 
      done"""
  when defined(windows):
    exec "echo This command is implemented using Bash specific shell commands. Instead, use genlevel for each level manually."

task perftest, "Run performance testing for the solution checking algorithm":
  when defined(posix):
    exec "nim --hints:off r -d:lto -d:danger -d:measurePerf tests/tlevelsolutions.nim"
  when defined(windows):
    exec r"nim --hints:off r -d:lto -d:danger -d:measurePerf tests\tlevelsolutions.nim"
