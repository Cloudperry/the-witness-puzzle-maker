import std/[tables, sets, sequtils]
import frosty/streams
import graphs, geometry

type
  Color* = tuple[r, g, b: int]
  PointKind* = enum ## All the puzzle symbols that can be attached to a point
    Empty, Start, End, Hex
  CellKind* = enum ## All the puzzle symbols that can be attached to a cell
    Empty, Square, Triangles, Star, Block, AntiBlock, Jack
  MazeCell* = object
    # NIMNOTE: Here kind is one field in the object, but the other fields the
    # object has depends on the value of kind. For example squares have a color
    # field, but no shape field and Blocks have the opposite. 
    case kind*: CellKind 
    of Square, Star: ## Only these puzzle symbols have a customizable color
      color*: Color  ## The color will affect the puzzle solution
    of Triangles:
      count*: int
    of Block, AntiBlock:
      shape*: seq[Point2DInt] ## Polyomino shape as a collection of points.
    else:                     ## (0, 0) is the top left corner of the shape.
      discard
    
  Level* = object
    # A bit later I will add support for arbitrary maze shapes
    # For that the field below will be used to determine the coordinate space of the level
    # borderVertices*: seq[Point2D]
    # Right now the coordinate space of the level is determined by the 2 following fields
    topLeftCorner*: Point2D
    botRightCorner*: Point2D
    pointGraph*: Graph[Point2D]
    cellGraph*: Graph[seq[Point2D]]
    pointData*: Table[Point2D, PointKind]
    cellData*: Table[seq[Point2D], MazeCell]
    # Might need to add a color palette definition later for convenience 
    # as the colors will be reused a lot in the same level
    fgColor*: Color
    bgColor*: Color
    lineColor*: Color

## Level editing primitives that are used by the level editor
proc makeEmptyGrid*(l: var Level; topLeftCorner, botRightCorner: Point2D) =
  for p1 in gridPoints(topLeftCorner, botRightCorner):
    # Create lines around a maze cell
    l.pointData[p1] = Empty
    for p2 in [p1 + (1.0, 0.0), p1 + (0.0, 1.0)]:
      if p2.x <= 4.0 and p2.y <= 4.0:
        l.pointGraph.addEdgeAndMissingNodes(p1, p2)
    # Create empty maze cell
    if p1.x in 0.0 .. 3.0 and p1.y in 0.0 .. 3.0:
      let cell = @[p1, p1 + (1.0, 0.0), p1 + (1.0, 1.0), p1 + (0.0, 1.0)]
      l.cellGraph.addNode(cell)
      l.cellData[cell] = MazeCell(kind: Empty)
  # Connect all the adjacent cells together in the graph
  for cell in l.cellGraph.nodes:
    let cellToRight = cell.mapIt(it + (1.0, 0.0))
    let cellBelow = cell.mapIt(it + (0.0, 1.0))
    if cellToRight in l.cellGraph:
      l.cellGraph.addEdge(cell, cellToRight)
    if cellBelow in l.cellGraph:
      l.cellGraph.addEdge(cell, cellBelow)

proc setPointData*(l: var Level, pointData: Table[Point2D, PointKind]) = 
  for point, kind in pointData:
    if point in l.pointGraph:
      l.pointData[point] = kind

proc setCellData*(l: var Level, cellData: Table[seq[Point2D], MazeCell]) = 
  for cell, data in cellData:
    if cell in l.cellGraph:
      l.cellData[cell] = data

## Saving and loading levels is implemented below
# Weird workaround used because of openFileStream errors. According to frosty sample code
# I shouldn't need to import std/streams at all.
#TODO: Maybe all the hash tables and sets in the level should be shrinked down to exactly the length
# of their elements before saving it to a file. That way the level file will be much smaller and it
# helps with iteration performance as well.
import std/streams as s
proc saveLevelToFile*(l: Level, filename: string) =
  var handle = openFileStream(filename, fmWrite)
  freeze(handle, l)
  close handle

proc loadLevelFromFile*(filename: string): Level =
  var handle = openFileStream(filename, fmRead)
  thaw(handle, result)
  close handle
