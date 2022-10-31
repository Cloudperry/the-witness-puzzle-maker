import std/strformat
import ../src/[game, geometry]

type 
  LevelSolutionsTest = object
    levelName: string
    correctLines: seq[Line]
    incorrectLines: seq[Line]

let tests = [
  LevelSolutionsTest(
    levelName: "hex-tutorial1",
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
  LevelSolutionsTest(
    levelName: "hex-tutorial2",
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
  LevelSolutionsTest(
    levelName: "shipwreck-triangles",
    correctLines: @[
      (0.0, 3.0) -> (1.0, 3.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> (2.0, 2.0) -> 
      (1.0, 2.0) -> (1.0, 1.0) -> (2.0, 1.0) -> (3.0, 1.0) -> (3.0, 0.0) -> (3.25, -0.25)
    ],
    incorrectLines: @[
      (0.0, 3.0) -> (1.0, 3.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> 
      (2.0, 2.0) -> (2.0, 1.0) -> (3.0, 1.0) -> (3.0, 0.0) -> (3.25, -0.25)
    ]
  ),
  LevelSolutionsTest(
    levelName: "treehouse-yellowbridge-puzzle8",
    correctLines: @[
      (1.5, 3.0) -> (1.0, 3.0) -> (0.0, 3.0) -> (0.0, 2.0) -> (1.0, 2.0) -> 
      (2.0, 2.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> (3.0, 1.0) ->
      (3.0, 0.0) -> (2.0, 0.0) -> (2.0, 1.0) -> (1.0, 1.0) -> (0.0, 1.0) -> 
      (0.0, 0.0) -> (1.0, 0.0) -> (1.5, 0.0) -> (1.5, -0.25)
    ],
    incorrectLines: @[
      (1.5, 3.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) -> (2.0, 2.0) ->
      (1.0, 2.0) -> (1.0, 3.0) -> (0.0, 3.0) -> (0.0, 2.0) -> (0.0, 1.0) ->
      (0.0, 0.0) -> (1.0, 0.0) -> (1.0, 1.0) -> (2.0, 1.0) -> (2.0, 0.0) ->
      (1.5, 0.0) -> (1.5, -0.25),
      # This line groups 4 stars together when stars should be paired
      (1.5, 3.0) -> (1.0, 3.0) -> (0.0, 3.0) -> (0.0, 2.0) -> (1.0, 2.0) ->
      (2.0, 2.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (1.5, 0.0) -> (1.5, -0.25)
    ]
  ),
  LevelSolutionsTest(
    levelName: "entryarea-secretdoor",
    correctLines: @[
      (6.0, 4.0) -> (6.5, 4.0) -> (7.0, 4.0) -> (7.0, 3.5) -> (7.0, 3.0) -> 
      (7.0, 2.0) -> (7.0, 1.0) -> (7.0, 0.5) -> (7.0, 0.0) -> (6.5, 0.0) ->
      (6.0, 0.0) -> (6.0, 1.0) -> (6.0, 2.0) -> (5.0, 2.0) -> (4.0, 2.0) ->
      (3.0, 2.0) -> (2.0, 2.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (1.0, 0.0) ->
      (1.0, 1.0) -> (0.0, 1.0) -> (0.0, 2.0) -> (0.0, 3.0) -> (0.0, 4.0) ->
      (1.0, 4.0) -> (2.0, 4.0) -> (3.0, 4.0) -> (3.0, 5.0) -> (2.0, 5.0) ->
      (1.5, 5.0) -> (1.0, 5.0) -> (0.0, 5.0) -> (0.0, 6.0) -> (0.0, 6.5) ->
      (0.0, 7.0) -> (0.5, 7.0) -> (1.0, 7.0) -> (2.0, 7.0) -> (3.0, 7.0) ->
      (4.0, 7.0) -> (5.0, 7.0) -> (5.5, 7.0) -> (6.0, 7.0) -> (6.0, 6.0) ->
      (6.0, 5.0) -> (7.0, 5.0) -> (7.0, 6.0) -> (7.0, 7.0) -> (7.25, 7.0)
    ],
    incorrectLines: @[
      (6.0, 4.0) -> (6.5, 4.0) -> (7.0, 4.0) -> (7.0, 3.5) -> (7.0, 3.0) ->
      (7.0, 2.0) -> (7.0, 1.0) -> (7.0, 0.5) -> (7.0, 0.0) -> (6.5, 0.0) ->
      (6.0, 0.0) -> (6.0, 1.0) -> (5.0, 1.0) -> (5.0, 2.0) -> (4.0, 2.0) ->
      (3.0, 2.0) -> (3.0, 1.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (1.0, 0.0) ->
      (1.0, 1.0) -> (0.0, 1.0) -> (0.0, 2.0) -> (0.0, 3.0) -> (0.0, 4.0) ->
      (1.0, 4.0) -> (2.0, 4.0) -> (3.0, 4.0) -> (3.0, 5.0) -> (2.0, 5.0) ->
      (1.5, 5.0) -> (1.0, 5.0) -> (0.0, 5.0) -> (0.0, 6.0) -> (0.0, 6.5) ->
      (0.0, 7.0) -> (0.5, 7.0) -> (1.0, 7.0) -> (2.0, 7.0) -> (3.0, 7.0) ->
      (4.0, 7.0) -> (5.0, 7.0) -> (5.5, 7.0) -> (6.0, 7.0) -> (6.0, 6.0) ->
      (7.0, 6.0) -> (7.0, 7.0) -> (7.25, 7.0)
    ]
  ),
  LevelSolutionsTest(
    levelName: "quarry-metalplatform-panel2",
    correctLines: @[
      (0.0, 3.0) -> (1.0, 3.0) -> (2.0, 3.0) -> (3.0, 3.0) -> (3.0, 2.0) ->
      (3.0, 1.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (3.0, 0.0) -> (3.25, -0.25)
    ],
    incorrectLines: @[
      (0.0, 3.0) -> (1.0, 3.0) -> (2.0, 3.0) -> (2.0, 2.0) -> (2.0, 1.0) ->
      (2.0, 0.0) -> (3.0, 0.0) -> (3.25, -0.25)]
  ),
  LevelSolutionsTest(
    levelName: "quarry-boathouse-metalplatform-panel7",
    correctLines: @[
      (0.0, 4.0) -> (1.0, 4.0) -> (1.0, 3.0) -> (1.0, 2.0) -> (0.0, 2.0) ->
      (0.0, 1.0) -> (0.0, 0.0) -> (1.0, 0.0) -> (1.0, 1.0) -> (2.0, 1.0) ->
      (2.0, 2.0) -> (2.0, 3.0) -> (2.0, 4.0) -> (3.0, 4.0) -> (3.0, 3.0) ->
      (3.0, 2.0) -> (3.0, 1.0) -> (3.0, 0.0) -> (4.0, 0.0) -> (4.25, -0.25)
    ],
    incorrectLines: @[
      (0.0, 4.0) -> (1.0, 4.0) -> (1.0, 3.0) -> (1.0, 2.0) -> (0.0, 2.0) ->
      (0.0, 1.0) -> (0.0, 0.0) -> (1.0, 0.0) -> (2.0, 0.0) -> (3.0, 0.0) ->
      (3.0, 1.0) -> (2.0, 1.0) -> (2.0, 2.0) -> (2.0, 3.0) -> (3.0, 3.0) ->
      (4.0, 3.0) -> (4.0, 2.0) -> (4.0, 1.0) -> (4.0, 0.0) -> (4.25, -0.25)
    ]
  ),
  LevelSolutionsTest(
    levelName: "treehouse-purplebridge-puzzle9",
    correctLines: @[
      (1.5, 3.0) -> (1.0, 3.0) -> (0.0, 3.0) -> (0.0, 2.0) -> (0.0, 1.0) ->
      (1.0, 1.0) -> (1.0, 2.0) -> (2.0, 2.0) -> (2.0, 3.0) -> (3.0, 3.0) ->
      (3.0, 2.0) -> (3.0, 1.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (1.5, 0.0) ->
      (1.5, -0.25)
    ],
    incorrectLines: @[
      (1.5, 3.0) -> (1.0, 3.0) -> (0.0, 3.0) -> (0.0, 2.0) -> (0.0, 1.0) ->
      (0.0, 0.0) -> (1.0, 0.0) -> (1.0, 1.0) -> (1.0, 2.0) -> (2.0, 2.0) ->
      (3.0, 2.0) -> (3.0, 1.0) -> (3.0, 0.0) -> (2.0, 0.0) -> (1.5, 0.0) ->
      (1.5, -0.25)
    ]
  ),
  LevelSolutionsTest(
    levelName: "treehouse-purplebridge-puzzle11",
    correctLines: @[
      (2.5, 4.0) -> (3.0, 4.0) -> (4.0, 4.0) -> (5.0, 4.0) -> (5.0, 3.0) ->
      (5.0, 2.0) -> (5.0, 1.0) -> (4.0, 1.0) -> (4.0, 2.0) -> (4.0, 3.0) ->
      (3.0, 3.0) -> (2.0, 3.0) -> (2.0, 2.0) -> (1.0, 2.0) -> (0.0, 2.0) ->
      (0.0, 1.0) -> (1.0, 1.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (2.5, 0.0) ->
      (2.5, -0.25)
    ],
    incorrectLines: @[
      (2.5, 4.0) -> (2.0, 4.0) -> (1.0, 4.0) -> (0.0, 4.0) -> (0.0, 3.0) ->
      (0.0, 2.0) -> (1.0, 2.0) -> (2.0, 2.0) -> (2.0, 3.0) -> (3.0, 3.0) ->
      (3.0, 4.0) -> (4.0, 4.0) -> (4.0, 3.0) -> (4.0, 2.0) -> (4.0, 1.0) ->
      (3.0, 1.0) -> (2.0, 1.0) -> (1.0, 1.0) -> (0.0, 1.0) -> (0.0, 0.0) ->
      (1.0, 0.0) -> (2.0, 0.0) -> (2.5, 0.0) -> (2.5, -0.25)
    ]
  ),
  LevelSolutionsTest(
    levelName: "treehouse-top-orangebridge-puzzle4",
    correctLines: @[
      (2.0, 4.0) -> (1.0, 4.0) -> (0.0, 4.0) -> (0.0, 3.0) -> (0.0, 2.0) ->
      (0.0, 1.0) -> (1.0, 1.0) -> (1.0, 2.0) -> (1.0, 3.0) -> (2.0, 3.0) ->
      (3.0, 3.0) -> (4.0, 3.0) -> (4.0, 2.0) -> (3.0, 2.0) -> (2.0, 2.0) ->
      (2.0, 1.0) -> (2.0, 0.0) -> (2.0, -0.25)
    ],
    incorrectLines: @[
      (2.0, 4.0) -> (3.0, 4.0) -> (4.0, 4.0) -> (4.0, 3.0) -> (3.0, 3.0) ->
      (2.0, 3.0) -> (2.0, 2.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (2.0, -0.25)
    ]
  ),
  LevelSolutionsTest(
    levelName: "swamp-redpanel4",
    correctLines: @[
      (0.0, 5.0) -> (1.0, 5.0) -> (1.0, 4.0) -> (2.0, 4.0) -> (3.0, 4.0) ->
      (4.0, 4.0) -> (4.0, 3.0) -> (4.0, 2.0) -> (4.0, 1.0) -> (3.0, 1.0) ->
      (2.0, 1.0) -> (1.0, 1.0) -> (0.0, 1.0) -> (0.0, 0.0) -> (1.0, 0.0) ->
      (2.0, 0.0) -> (3.0, 0.0) -> (4.0, 0.0) -> (5.0, 0.0) -> (5.0, -0.25),
      (0.0, 5.0) -> (1.0, 5.0) -> (1.0, 4.0) -> (2.0, 4.0) -> (3.0, 4.0) ->
      (4.0, 4.0) -> (4.0, 3.0) -> (4.0, 2.0) -> (5.0, 2.0) -> (5.0, 1.0) ->
      (4.0, 1.0) -> (3.0, 1.0) -> (3.0, 2.0) -> (2.0, 2.0) -> (2.0, 1.0) ->
      (1.0, 1.0) -> (0.0, 1.0) -> (0.0, 0.0) -> (1.0, 0.0) -> (2.0, 0.0) ->
      (3.0, 0.0) -> (4.0, 0.0) -> (5.0, 0.0) -> (5.0, -0.25),
      (0.0, 5.0) -> (1.0, 5.0) -> (1.0, 4.0) -> (1.0, 3.0) -> (1.0, 2.0) ->
      (2.0, 2.0) -> (2.0, 3.0) -> (2.0, 4.0) -> (3.0, 4.0) -> (4.0, 4.0) ->
      (5.0, 4.0) -> (5.0, 3.0) -> (5.0, 2.0) -> (4.0, 2.0) -> (4.0, 1.0) ->
      (3.0, 1.0) -> (2.0, 1.0) -> (1.0, 1.0) -> (0.0, 1.0) -> (0.0, 0.0) ->
      (1.0, 0.0) -> (2.0, 0.0) -> (3.0, 0.0) -> (4.0, 0.0) -> (5.0, 0.0) ->
      (5.0, -0.25)
    ],
    incorrectLines: @[
      (0.0, 5.0) -> (1.0, 5.0) -> (1.0, 4.0) -> (1.0, 3.0) -> (1.0, 2.0) ->
      (2.0, 2.0) -> (2.0, 3.0) -> (2.0, 4.0) -> (3.0, 4.0) -> (4.0, 4.0) ->
      (5.0, 4.0) -> (5.0, 3.0) -> (5.0, 2.0) -> (5.0, 1.0) -> (4.0, 1.0) ->
      (3.0, 1.0) -> (3.0, 0.0) -> (4.0, 0.0) -> (5.0, 0.0) -> (5.0, -0.25),
      (0.0, 5.0) -> (1.0, 5.0) -> (2.0, 5.0) -> (3.0, 5.0) -> (4.0, 5.0) ->
      (5.0, 5.0) -> (5.0, 4.0) -> (5.0, 3.0) -> (5.0, 2.0) -> (5.0, 1.0) ->
      (5.0, 0.0) -> (5.0, -0.25)
    ]
  )
]

when not defined(measurePerf): # Normal testing mode
  for test in tests: 
    # Check that the solution checker accepts all the correct solutions
    var game: GameState
    game.init(fmt"levels/{test.levelName}.bin")
    for line in test.correctLines:
      game.setLine line
      assert(
        line.goesFromStartToEnd(game.level) and game.checkSolution(),
        fmt"Level {test.levelName} line {line} should be a correct solution"
      ) 
    # Check that the solution checker denies all the wrong solutions
    for line in test.incorrectLines:
      game.setLine line
      assert(
        not (line.goesFromStartToEnd(game.level) and game.checkSolution()),
        fmt"Level {test.levelName} line {line} should be an incorrect solution"
      ) 

  echo fmt"level solution checking algorithm (game.nim) tests ran successfully."
else: # Performance testing mode
  import std/[monotimes, times, tables, sequtils, math]
  var checkTimes: Table[string, int]

  for test in tests: 
    var game: GameState
    game.init fmt"levels/{test.levelName}.bin"
    let before = getMonoTime()
    for i in 1 .. 5:
      # Initialize game without reloading the level from disk
      game.init game.level
      # Check that the solution checker accepts all the correct solutions
      for line in test.correctLines:
        game.setLine line
        assert(
          line.goesFromStartToEnd(game.level) and game.checkSolution(),
          fmt"Level {test.levelName} line {line} should be a correct solution"
        ) 
      # Check that the solution checker denies all the wrong solutions
      for line in test.incorrectLines:
        game.setLine line
        assert(
          not (line.goesFromStartToEnd(game.level) and game.checkSolution()),
          fmt"Level {test.levelName} line {line} should be an incorrect solution"
        ) 
    let after = getMonoTime()
    checkTimes[test.levelName] = (inNanoseconds(after - before).int / 5 / 1000).int

  echo fmt"level solution checking algorithm (game.nim) tests ran successfully in {checkTimes.values.toSeq().sum()} µs."
  echo fmt"per-level times: {checkTimes}"
