import std/tables
import ../src/levels

var yellowBridgePuzzle8, topOrangeBridgePuzzle4 = Level(
  bgColor: (110, 70, 50),
  fgColor: (60, 50, 50),
  lineColor: (255, 255, 255)
)

yellowBridgePuzzle8.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))
yellowBridgePuzzle8.addPointBetween((1.0, 3.0), (2.0, 3.0), Start)
yellowBridgePuzzle8.addPointBetween((1.0, 0.0), (2.0, 0.0))
yellowBridgePuzzle8.addConnectedPoint((1.5, -0.25), End, (1.5, 0.0))
yellowBridgePuzzle8.setCellData({
  MazeCell(kind: Star, color: (245, 100, 0)): @[
    (0.0, 0.0), (1.0, 0.0), (2.0, 0.0), (0.0, 2.0), (1.0, 2.0), (2.0, 2.0)
  ]
}.toTable)

topOrangeBridgePuzzle4.makeEmptyGrid((0.0, 0.0), (4.0, 4.0))
topOrangeBridgePuzzle4.setPointData({Start: @[(2.0, 4.0)]}.toTable)
topOrangeBridgePuzzle4.addConnectedPoint((2.0, -0.25), End, (2.0, 0.0))
topOrangeBridgePuzzle4.setCellData({
  MazeCell(kind: Square, color: (0, 0, 0)): @[
    (0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)
  ],
  MazeCell(kind: Square, color: (255, 255, 255)): @[
    (2.0, 0.0), (3.0, 0.0), (2.0, 1.0), (3.0, 1.0)
  ],
  MazeCell(kind: Star, color: (0, 0, 0)): @[
    (3.0, 3.0)
  ]
}.toTable)

let purpleBridgePuzzle = Level(
  bgColor: (85, 105, 105),
  fgColor: (25, 40, 40),
  lineColor: (240, 250, 240)
)

var purpleBridgePuzzle9, purpleBridgePuzzle11 = purpleBridgePuzzle
purpleBridgePuzzle9.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))
purpleBridgePuzzle9.addPointBetween((1.0, 3.0), (2.0, 3.0), Start)
purpleBridgePuzzle9.addPointBetween((1.0, 0.0), (2.0, 0.0))
purpleBridgePuzzle9.addConnectedPoint((1.5, -0.25), End, (1.5, 0.0))
purpleBridgePuzzle9.setCellData({
  MazeCell(kind: Square, color: (250, 135, 20)): @[
    (0.0, 0.0), (2.0, 2.0)
  ],
  MazeCell(kind: Square, color: (0, 0, 0)): @[
    (2.0, 0.0), (0.0, 2.0)
  ],
  MazeCell(kind: Star, color: (255, 255, 255)): @[
    (1.0, 0.0), (0.0, 1.0), (2.0, 1.0), (1.0, 2.0)
  ]
}.toTable)

purpleBridgePuzzle11.makeEmptyGrid((0.0, 0.0), (5.0, 4.0))
purpleBridgePuzzle11.addPointBetween((2.0, 4.0), (3.0, 4.0), Start)
purpleBridgePuzzle11.addPointBetween((2.0, 0.0), (3.0, 0.0))
purpleBridgePuzzle11.addConnectedPoint((2.5, -0.25), End, (2.5, 0.0))
purpleBridgePuzzle11.setCellData({
  MazeCell(kind: Star, color: (190, 70, 230)): @[
    (0.0, 0.0), (1.0, 0.0), (3.0, 1.0), (3.0, 2.0), (0.0, 2.0), (1.0, 2.0)
  ],
  MazeCell(kind: Square, color: (110, 245, 30)): @[
    (2.0, 0.0), (0.0, 1.0), (1.0, 1.0), (2.0, 1.0)
  ],
  MazeCell(kind: Square, color: (250, 135, 20)): @[
    (4.0, 1.0), (4.0, 2.0), (0.0, 3.0), (1.0, 3.0)
  ],
}.toTable)

yellowBridgePuzzle8.saveLevelToFile("treehouse-yellowbridge-puzzle8.bin")
purpleBridgePuzzle9.saveLevelToFile("treehouse-purplebridge-puzzle9.bin")
purpleBridgePuzzle11.saveLevelToFile("treehouse-purplebridge-puzzle11.bin")
topOrangeBridgePuzzle4.saveLevelToFile("treehouse-top-orangebridge-puzzle4.bin")
