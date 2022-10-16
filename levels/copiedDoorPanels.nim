import std/[tables, sets, sugar]
import ../src/levels, ../src/graphs, ../src/geometry

var entryAreaDoor = Level(
  bgColor: (195, 195, 195),
  fgColor: (110, 110, 110),
  lineColor: (190, 255, 230)
)

entryAreaDoor.makeEmptyGrid((0.0, 0.0), (7.0, 7.0))
entryAreaDoor.addConnectedPoint(End, (-0.25, 0.0), (0.0, 0.0))
entryAreaDoor.addConnectedPoint(End, (7.25, 0.0), (7.0, 0.0))
entryAreaDoor.addConnectedPoint(End, (7.25, 7.0), (7.0, 7.0))
entryAreaDoor.setPointData({
  Start: @[(4.0, 2.0), (6.0, 4.0), (2.0, 5.0), (0.0, 7.0)]
}.toTable)
entryAreaDoor.addPointBetween(Hex, (6.0, 0.0), (7.0, 0.0))
entryAreaDoor.addPointBetween(Hex, (7.0, 1.0), (7.0, 0.0))
entryAreaDoor.addPointBetween(Hex, (7.0, 3.0), (7.0, 4.0))
entryAreaDoor.addPointBetween(Hex, (6.0, 4.0), (7.0, 4.0))
entryAreaDoor.addPointBetween(Hex, (1.0, 5.0), (2.0, 5.0))
entryAreaDoor.addPointBetween(Hex, (0.0, 6.0), (0.0, 7.0))
entryAreaDoor.addPointBetween(Hex, (0.0, 7.0), (1.0, 7.0))
entryAreaDoor.addPointBetween(Hex, (5.0, 7.0), (6.0, 7.0))
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
#let symbols = collect:
#  for cell, symbol in entryAreaDoor.cellData.pairs:
#    if symbol.kind != Empty:
#      {cell: symbol}
#echo symbols

entryAreaDoor.saveLevelToFile("entryAreaDoor.bin")
