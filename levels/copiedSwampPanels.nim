import std/tables
import ../src/levels

var swampRedPanel4 = Level(
  bgColor: (30, 35, 40),
  fgColor: (55, 80, 80),
  lineColor: (255, 255, 255)
)

swampRedPanel4.makeEmptyGrid((0.0, 0.0), (5.0, 5.0))
swampRedPanel4.setPointData({Start: @[(0.0, 5.0)]}.toTable)
swampRedPanel4.addConnectedPoint((5.0, -0.25), End, (5.0, 0.0))
swampRedPanel4.setCellData({
  newLineOrLBlock((2, 0), (-2, 1)): @[(0.0, 0.0)],
  newLineOrLBlock((0, 0), (1, 0)): @[(4.0, 0.0)],
  newLineOrLBlock((0, 0), (0, 2)): @[(1.0, 4.0)],
  newLineOrLBlock((0, 0), (2, 0)): @[(4.0, 4.0)]
}.toTable)

swampRedPanel4.saveLevelToFile("swamp-redpanel4.bin")
