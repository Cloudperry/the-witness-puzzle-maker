import std/[tables, sets, lenientops, os]
import ../src/levels, ../src/graphs, ../src/geometry

var shipwreckTriangles = Level(
  bgColor: (240, 240, 240),
  fgColor: (150, 130, 100),
  lineColor: (255, 155, 90)
)

shipwreckTriangles.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))
shipwreckTriangles.setPointData({Start: @[(0.0, 3.0)]}.toTable)
shipwreckTriangles.addConnectedPoint(End, (3.25, -0.25), (3.0, 0.0))
shipwreckTriangles.removeEdges(
  ((2.0, 0.0), (3.0, 0.0)), ((0.0, 1.0), (0.0, 2.0)), ((3.0, 1.0), (3.0, 2.0)),
  ((2.0, 2.0), (2.0, 3.0))
)
shipwreckTriangles.setCellData({MazeCell(kind: Triangles, count: 2): @[cellFromTopLeft((2.0, 1.0))]}.toTable)

shipwreckTriangles.saveLevelToFile("shipwreckTriangles.bin")
