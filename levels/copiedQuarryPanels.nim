import std/tables
import ../src/levels

var quarryMetalBridgePanel2 = Level(
  bgColor: (30, 35, 40),
  fgColor: (55, 80, 80),
  lineColor: (255, 255, 255)
)

quarryMetalBridgePanel2.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))
quarryMetalBridgePanel2.setPointData({Start: @[(0.0, 3.0)]}.toTable)
quarryMetalBridgePanel2.addConnectedPoint((3.25, -0.25), End, (3.0, 0.0))
quarryMetalBridgePanel2.setCellData({
  MazeCell(kind: Square, color: (245, 100, 0)): @[
    cellFromTopLeft((1.0, 0.0)), cellFromTopLeft((2.0, 1.0))
  ],
  MazeCell(kind: Square, color: (255, 255, 255)): @[
    cellFromTopLeft((2.0, 0.0)), cellFromTopLeft((1.0, 1.0))
  ],
  MazeCell(kind: Jack): @[
    cellFromTopLeft((0.0, 2.0))
  ]
}.toTable)


var quarryBoathouseMetalBridgePanel7 = Level(
  bgColor: (30, 35, 40),
  fgColor: (55, 80, 80),
  lineColor: (255, 255, 255)
)

quarryBoathouseMetalBridgePanel7.makeEmptyGrid((0.0, 0.0), (4.0, 4.0))
quarryBoathouseMetalBridgePanel7.addConnectedPoint((4.25, -0.25), End, (4.0, 0.0))
quarryBoathouseMetalBridgePanel7.setPointData({Start: @[(0.0, 4.0)]}.toTable)
quarryBoathouseMetalBridgePanel7.setCellData({
  MazeCell(kind: Star, color: (245, 100, 0)): @[
    (0.0, 0.0), (1.0, 0.0), (2.0, 0.0), (3.0, 0.0), (0.0, 1.0), (3.0, 1.0),
    (0.0, 2.0), (3.0, 2.0), (0.0, 3.0)
  ],
  MazeCell(kind: Jack): @[(3.0, 3.0)]
}.toTable)

quarryMetalBridgePanel2.saveLevelToFile("quarry-metalplatform-panel2.bin")
quarryBoathouseMetalBridgePanel7.saveLevelToFile("quarry-boathouse-metalplatform-panel7.bin")
