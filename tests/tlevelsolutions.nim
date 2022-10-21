import std/[strformat, tables, sets, lenientops, os]
import ../src/[levels, game, geometry]

type 
  LevelSolutions = object
    level: Level
    correctLines: seq[Line]
    incorrectLines: seq[Line]

let levelsAndSolutions = {
  "hexTutorial1": LevelSolutions(
    level: loadLevelFromFile("levels/hexTutorial1.bin"),
    correctLines: @[
      (0.0, 2.0) -> (0.0, 1.0) -> (0.0, 0.0) -> (1.0, 0.0) -> (1.0, 1.0) -> 
      (1.0, 2.0) -> (2.0, 2.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (2.0, -0.25)
    ],
    incorrectLines: @[
      # This line is wrong because it doesn't start from a start point
      (0.0, 0.0) -> (1.0, 0.0) -> (1.0, 1.0) -> (1.0, 2.0) -> (2.0, 2.0) -> 
      (2.0, 1.0) -> (2.0, 0.0) -> (2.0, -0.25),
      # This line is wrong because it doesn't go through any of the hexes
      (0.0, 2.0) -> (1.0, 2.0) -> (1.0, 1.0) -> (2.0, 1.0) -> (2.0, 0.0) ->
      (2.0, -0.25)
    ]
  ),
  "hexTutorial2": LevelSolutions(
    level: loadLevelFromFile("levels/hexTutorial2.bin"),
    correctLines: @[
      (0.0, 3.0) -> (0.0, 2.0) -> (1.0, 2.0) -> (1.0, 3.0) -> (2.0, 3.0) -> 
      (3.0, 3.0) -> (3.0, 2.0) -> (2.0, 2.0) -> (2.0, 1.0) -> (1.0, 1.0) -> 
      (1.0, 0.0) -> (2.0, 0.0) -> (3.0, 0.0) -> (3.0, -0.25),
      (0.0, 3.0) -> (0.0, 2.0) -> (0.0, 1.0) -> (1.0, 1.0) -> (1.0, 0.0) ->
      (2.0, 0.0) -> (2.0, 1.0) -> (2.0, 2.0) -> (1.0, 2.0) -> (1.0, 3.0) ->
      (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> (3.0, 1.0) -> (3.0, 0.0) ->
      (3.0, -0.25)
    ],
    incorrectLines: @[
      (0.0, 3.0) -> (0.0, 2.0) -> (1.0, 2.0) -> (1.0, 1.0) -> (1.0, 0.0) -> 
      (2.0, 0.0) -> (2.0, 1.0) -> (2.0, 2.0) -> (3.0, 2.0) -> (3.0, 1.0) -> 
      (3.0, 0.0) -> (3.0, -0.25)
    ]
  ),
  "shipwreckTriangles": LevelSolutions(
    level: loadLevelFromFile("levels/shipwreckTriangles.bin"),
    correctLines: @[
      (0.0, 3.0) -> (1.0, 3.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> (2.0, 2.0) -> 
      (1.0, 2.0) -> (1.0, 1.0) -> (2.0, 1.0) -> (3.0, 1.0) -> (3.0, 0.0) -> (3.25, -0.25)
    ],
    incorrectLines: @[
      (0.0, 3.0) -> (1.0, 3.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> 
      (2.0, 2.0) -> (2.0, 1.0) -> (3.0, 1.0) -> (3.0, 0.0) -> (3.25, -0.25)
    ]
  ),
  "treehouseBridge1Puzzle8": LevelSolutions(
    level: loadLevelFromFile("levels/treehouseBridge1Puzzle8.bin"),
    correctLines: @[
      (1.5, 3.0) -> (1.0, 3.0) -> (0.0, 3.0) -> (0.0, 2.0) -> (1.0, 2.0) -> 
      (2.0, 2.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> (3.0, 1.0) ->
      (3.0, 0.0) -> (2.0, 0.0) -> (2.0, 1.0) -> (1.0, 1.0) -> (0.0, 1.0) -> 
      (0.0, 0.0) -> (1.0, 0.0) -> (1.5, 0.0) -> (1.5, -0.25)
    ]
  ),
  "quarryMetalBridgePanel2": LevelSolutions(
    level: loadLevelFromFile("levels/quarryMetalBridgePanel2.bin"),
  )
}.toTable

for name, level in levelsAndSolutions: 
  # Check that the solution checker accepts all the correct solutions
  for line in level.correctLines:
    assert(
      line.goesFromStartToEnd(level.level) and level.level.checkSolution(line),
      fmt"Level {name} line {line} should be a correct solution"
    ) 
  # Check that the solution checker denies all the wrong solutions
  for line in level.incorrectLines:
    assert(
      not (line.goesFromStartToEnd(level.level) and level.level.checkSolution(line)),
      fmt"Level {name} line {line} should be an incorrect solution"
    ) 

echo "level solution algorithm (game.nim) tests ran successfully."
