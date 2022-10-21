import std/[tables, sets, lenientops, os]
import ../src/[levels, graphs]

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
  Hex: @[(1.0, 1.0)], Start: @[(0.0, 4.0)], End: @[(3.0, 4.25)]
}.toTable)
sampleLevel.setCellData({
  MazeCell(kind: Square, color: (255, 255, 255)): @[@[(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)]],
  MazeCell(kind: Star, color: (255, 140, 0)): @[@[(1.0, 0.0), (2.0, 0.0), (2.0, 1.0), (1.0, 1.0)]],
  MazeCell(kind: Triangles, count: 2): @[@[(1.0, 1.0), (2.0, 1.0), (2.0, 2.0), (1.0, 2.0)]],
  MazeCell(kind: Triangles, count: 3): @[@[(1.0, 2.0), (2.0, 2.0), (2.0, 3.0), (1.0, 3.0)]]
}.toTable)

sampleLevel.saveLevelToFile("testLevel.bin")
let sampleLevelFromDisk = loadLevelFromFile("testLevel.bin")
# Check that the level is the same after loading it from disk
assert sampleLevel == sampleLevelFromDisk
when not defined(saveLevel):
  removeFile("testLevel.bin")

echo "level format and editing library (levels.nim) tests ran successfully."
