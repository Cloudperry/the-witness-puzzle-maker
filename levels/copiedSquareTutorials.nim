import std/tables
import ../src/levels

var squareTutorial5 = Level(
  bgColor: (70, 70, 255),
  fgColor: (60, 50, 175),
  lineColor: (100, 150, 255)
)

squareTutorial5.makeEmptyGrid((0.0, 0.0), (3.0, 3.0))
squareTutorial5.addConnectedPoint((3.0, -0.25), End, (3.0, 0.0))
squareTutorial5.setPointData({
  Start: @[(0.0, 3.0)]
}.toTable)
squareTutorial5.setCellData({
  MazeCell(kind: Square, color: (0, 0, 0)): @[
    (0.0, 0.0), (1.0, 0.0), (2.0, 0.0), (0.0, 1.0), (2.0, 1.0)
  ],
  MazeCell(kind: Square, color: (255, 255, 255)): @[
    (1.0, 1.0), (0.0, 2.0), (1.0, 2.0), (2.0, 2.0)
  ],
}.toTable)

var squareTutorial6 = Level(
  bgColor: (70, 70, 255),
  fgColor: (60, 50, 175),
  lineColor: (100, 150, 255)
)

squareTutorial6 = squareTutorial5
squareTutorial6.removePoint (3.0, -0.25)
squareTutorial6.addConnectedPoint((-0.25, 2.0), End, (0.0, 2.0))

squareTutorial5.saveLevelToFile("square-tutorial5.bin")
squareTutorial6.saveLevelToFile("square-tutorial6.bin")
