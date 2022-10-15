import std/[tables, sets]
import ../src/levels, ../src/graphs, ../src/geometry

let levelBase = Level(
  bgColor: (0, 230, 80),
  fgColor: (0, 125, 45),
  lineColor: (240, 235, 155)
)

var level1, level2 = levelBase
level1.makeEmptyGrid((0.0, 0.0), (2.0, 2.0))
level2.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))

level1.pointData[(0.0, 2.0)] = Start
level1.addConnectedPoint((2.0, -0.25), (2.0, 0.0), End) # Add goal
level1.setPointData({
  (0.0, 0.0): Hex, (2.0, 2.0): Hex
}.toTable)

level2.pointData[(0.0, 3.0)] = Start
level2.addConnectedPoint((3.0, -0.25), (3.0, 0.0), End)
level2.removePoint((0.0, 0.0))
level2.setPointData({
  (0.0, 2.0): Hex, (1.0, 2.0): Hex, (1.0, 0.0): Hex, (2.0, 1.0): Hex,
  (3.0, 3.0): Hex
}.toTable)
level2.pointGraph.removeEdge((2.0, 2.0), (2.0, 3.0))
level2.pointGraph.removeEdge((2.0, 1.0), (3.0, 1.0))

level1.saveLevelToFile("hexTutorial1.bin")
level2.saveLevelToFile("hexTutorial2.bin")
