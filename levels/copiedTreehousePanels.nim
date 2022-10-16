import std/[tables, sets, lenientops, os]
import ../src/levels, ../src/graphs, ../src/geometry

var treehouseBridge1Puzzle8 = Level(
  bgColor: (110, 70, 50),
  fgColor: (60, 50, 50),
  lineColor: (255, 255, 255)
)

treehouseBridge1Puzzle8.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))
treehouseBridge1Puzzle8.addPointBetween(Start, (1.0, 3.0), (2.0, 3.0))
treehouseBridge1Puzzle8.addPointBetween(Empty, (1.0, 0.0), (2.0, 0.0))
treehouseBridge1Puzzle8.addConnectedPoint(End, (1.5, -0.25), (1.5, 0.0))
treehouseBridge1Puzzle8.setCellData({
  MazeCell(kind: Star, color: (245, 100, 0)): @[
    cellFromTopLeft((0.0, 0.0)), cellFromTopLeft((1.0, 0.0)), 
    cellFromTopLeft((2.0, 0.0)), cellFromTopLeft((0.0, 2.0)),
    cellFromTopLeft((1.0, 2.0)), cellFromTopLeft((2.0, 2.0))
  ]
}.toTable)

treehouseBridge1Puzzle8.saveLevelToFile("treehouseBridge1Puzzle8.bin")
