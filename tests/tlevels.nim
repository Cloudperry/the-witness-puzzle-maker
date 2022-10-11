import std/[tables, sets, lenientops, os]
import ../src/levels, ../src/graphs, ../src/geometry

var sampleLevel = Level(
  topLeftCorner: (0.0, 0.0),
  botRightCorner: (4.0, 4.25),
  bgColor: (70, 70, 255),
  fgColor: (60, 50, 175),
  lineColor: (100, 150, 255)
)

sampleLevel.makeEmptyGrid((0.0, 0.0), (4.0, 4.0))
sampleLevel.pointGraph.addEdgeAndMissingNodes((3.0, 4.0), (3.0, 4.25))
sampleLevel.setPointData({
  (1.0, 1.0): Hex, (0.0, 4.0): Start, (3.0, 4.25): End
}.toTable)
sampleLevel.setCellData({
  @[(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)]: MazeCell(kind: Square, color: (255, 255, 255)),
  @[(1.0, 0.0), (2.0, 0.0), (2.0, 1.0), (1.0, 1.0)]: MazeCell(kind: Star, color: (255, 140, 0)),
  @[(1.0, 1.0), (2.0, 1.0), (2.0, 2.0), (1.0, 2.0)]: MazeCell(kind: Triangles, count: 2),
  @[(1.0, 2.0), (2.0, 2.0), (2.0, 3.0), (1.0, 3.0)]: MazeCell(kind: Triangles, count: 3)
}.toTable)

sampleLevel.saveLevelToFile("testLevel.bin")
let sampleLevelFromDisk = loadLevelFromFile("testLevel.bin")
# Check that the levels are equal. For now I'm comparing the string representations
# of the objects, because Nim doesn't support comparing objects that use some features.
# See https://forum.nim-lang.org/t/6781 for details.
assert $sampleLevel == $sampleLevelFromDisk
when not defined(saveLevel):
  removeFile("testLevel.bin")

echo "level format and editing library (levels.nim) test ran successfully."
