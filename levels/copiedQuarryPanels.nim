import std/[tables, sets, lenientops, os, options]
import ../src/[levels, graphs, geometry]

var quarryMetalBridgePanel2 = Level(
  bgColor: (110, 70, 50),
  fgColor: (60, 50, 50),
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

quarryMetalBridgePanel2.saveLevelToFile("quarryMetalBridgePanel2.bin")
