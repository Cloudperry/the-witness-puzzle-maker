import std/[tables, sets, sugar]
import ../src/levels

var entryAreaDoor = Level(
  bgColor: (195, 195, 195),
  fgColor: (110, 110, 110),
  lineColor: (190, 255, 230)
)

entryAreaDoor.makeEmptyGrid((0.0, 0.0), (7.0, 7.0))
entryAreaDoor.addConnectedPoint((-0.25, 0.0), End, (0.0, 0.0))
entryAreaDoor.addConnectedPoint((7.25, 0.0), End, (7.0, 0.0))
entryAreaDoor.addConnectedPoint((7.25, 7.0), End, (7.0, 7.0))
entryAreaDoor.setPointData({
  Start: @[(4.0, 2.0), (6.0, 4.0), (2.0, 5.0), (0.0, 7.0)]
}.toTable)
entryAreaDoor.addPointBetween((6.0, 0.0), (7.0, 0.0), Hex)
entryAreaDoor.addPointBetween((7.0, 1.0), (7.0, 0.0), Hex)
entryAreaDoor.addPointBetween((7.0, 3.0), (7.0, 4.0), Hex)
entryAreaDoor.addPointBetween((6.0, 4.0), (7.0, 4.0), Hex)
entryAreaDoor.addPointBetween((1.0, 5.0), (2.0, 5.0), Hex)
entryAreaDoor.addPointBetween((0.0, 6.0), (0.0, 7.0), Hex)
entryAreaDoor.addPointBetween((0.0, 7.0), (1.0, 7.0), Hex)
entryAreaDoor.addPointBetween((5.0, 7.0), (6.0, 7.0), Hex)
entryAreaDoor.setCellData({
  MazeCell(kind: Square, color: (0, 0, 0)): @[
    cellFromTopLeft((0.0, 0.0)), cellFromTopLeft((5.0, 0.0)), 
    cellFromTopLeft((3.0, 1.0)), cellFromTopLeft((4.0, 1.0)),
    cellFromTopLeft((2.0, 4.0)), cellFromTopLeft((6.0, 5.0)),
    cellFromTopLeft((6.0, 6.0))
  ],
  MazeCell(kind: Square, color: (255, 255, 255)): @[
    cellFromTopLeft((1.0, 0.0)), cellFromTopLeft((6.0, 0.0)), 
    cellFromTopLeft((0.0, 1.0)), cellFromTopLeft((3.0, 2.0)),
    cellFromTopLeft((4.0, 2.0)), cellFromTopLeft((2.0, 5.0)),
    cellFromTopLeft((5.0, 6.0))
  ]
}.toTable)

entryAreaDoor.saveLevelToFile("entryAreaDoor.bin")
