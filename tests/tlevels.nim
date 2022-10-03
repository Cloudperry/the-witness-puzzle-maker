import tables, sets, lenientops
import ../src/levels, ../src/graphs

# The following is a messy piece of code that creates a simple level by poking around
# in the data structures. The level format is not designed for manually constructing levels.
# The level constructed here corresponds to the rightmost level in the project definition 
# document (but this version has no square symbols).
var samplePointGraph: Graph[Point2D]
for p1 in gridPoints((0.0, 0.0), (4.0, 4.0)):
  samplePointGraph.addNode(p1)
for p1 in gridPoints((0.0, 0.0), (4.0, 4.0)):
  samplePointGraph.addNode(p1)
  for p2 in adjacentGridPoints(p1):
    if p2.x >= 0.0 and p2.x <= 4.0 and
    p2.y >= 0.0 and p2.y <= 4.0:
      samplePointGraph.addEdge(p1, p2)
samplePointGraph.addNode (3.0, 4.25) 
samplePointGraph.addEdge((3.0, 4.0), (3.0, 4.25))

var sampleCellGraph: Graph[seq[Point2D]]
var cells: Table[Point2D, seq[Point2D]]
for p in gridPoints((0.0, 0.0), (3.0, 3.0)):
  var cell: seq[Point2D]
  for delta in [(0, 0), (1, 0), (1, 1), (0, 1)]:
    cell.add (p.x + delta[0], p.y + delta[1])
  cells[p] = cell
  sampleCellGraph.addNode(cell)
  cell.setLen(0)
for p1 in cells.keys:
  for delta in [(1, 0), (0, 1)]:
    let p2 = (p1.x + delta[0], p1.y + delta[1])
    if p2 in cells:
      sampleCellGraph.addEdge(cells[p1], cells[p2])

var samplePointData: Table[Point2D, PointKind]
for p in gridPoints((0.0, 0.0), (4.0, 4.0)):
  samplePointData[p] = Empty
samplePointData[(0.0, 4.0)] = Start
samplePointData[(3.0, 4.25)] = End

var sampleCellData: Table[seq[Point2D], MazeCell]
for cell in cells.values:
  sampleCellData[cell] = MazeCell(kind: Empty)

let sampleLevel = Level(
  topLeftCorner: (0.0, 0.0),
  botRightCorner: (4.0, 4.0),
  pointGraph: samplePointGraph,
  cellGraph: sampleCellGraph,
  pointData: samplePointData,
  cellData: sampleCellData,
  bgColor: (70, 70, 255),
  fgColor: (60, 50, 175),
  lineColor: (100, 150, 255),
)

sampleLevel.saveLevelToFile("testLevel.bin")
let sampleLevelFromDisk = loadLevelFromFile("testLevel.bin")
# Check that the levels are equal. For now I'm comparing the string representations
# of the objects, because Nim doesn't support comparing objects that use some features.
# See https://forum.nim-lang.org/t/6781 for details.
assert $sampleLevel == $sampleLevelFromDisk

echo "level format and editing library (levels.nim) test ran successfully."
