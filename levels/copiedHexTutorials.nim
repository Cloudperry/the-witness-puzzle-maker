import std/[tables, sets]
import ../src/[levels, graphs]

let levelBase = Level(
  bgColor: (0, 230, 80),
  fgColor: (0, 125, 45),
  lineColor: (240, 235, 155)
)

var level1, level2 = levelBase
level1.makeEmptyGrid((0.0, 0.0), (2.0, 2.0))
level2.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))

level1.pointData[(0.0, 2.0)] = Start
level1.addConnectedPoint((2.0, -0.25), End, (2.0, 0.0)) # Add goal
level1.setPointData({
  Hex: @[(0.0, 0.0), (2.0, 2.0)]
}.toTable)

level2.pointData[(0.0, 3.0)] = Start
level2.addConnectedPoint((3.0, -0.25), End, (3.0, 0.0))
level2.removePoint((0.0, 0.0))
level2.setPointData({
  Hex: @[(0.0, 2.0), (1.0, 2.0), (1.0, 0.0), (2.0, 1.0), (3.0, 3.0)]
}.toTable)
level2.pointGraph.removeEdge((2.0, 2.0), (2.0, 3.0))
level2.pointGraph.removeEdge((2.0, 1.0), (3.0, 1.0))

level1.saveLevelToFile("hex-tutorial1.bin")
level2.saveLevelToFile("hex-tutorial2.bin")
