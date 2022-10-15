import std/[tables, sets, sequtils, options, math, sugar, strformat]
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
      if p2.x <= botRightCorner.x and p2.y <= botRightCorner.y:
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
      if point.x < l.topLeftCorner.x: l.topLeftCorner.x = point.x
      if point.y < l.topLeftCorner.y: l.topLeftCorner.y = point.y
      if point.x > l.botRightCorner.x: l.botRightCorner.x = point.x
      if point.y > l.botRightCorner.y: l.botRightCorner.y = point.y
      l.pointData[point] = kind

proc setCellData*(l: var Level, cellData: Table[seq[Point2D], MazeCell]) = 
  for cell, data in cellData:
    if cell in l.cellGraph:
      l.cellData[cell] = data

proc removePoint*(l: var Level, p: Point2D) =
  l.pointGraph.removeNode(p)
  l.pointData.del p

proc addConnectedPoint*(l: var Level, p, connectedTo: Point2D, kind: PointKind) =
  l.pointGraph.addEdgeAndMissingNodes(p, connectedTo)
  l.setPointData({p: kind}.toTable)

proc lineGoesFromStartToEnd(l: Level, line: LineSegments): bool = 
  var lineHasRoute = true
  for segment in line:
    if not l.pointGraph.hasRoute(segment.p1, segment.p2):
      lineHasRoute = false
  return l.pointData[line[0].p1] == Start and 
  l.pointData[line[^1].p2] == End and lineHasRoute

proc checkSolution*(l: Level, line: LineSegments): bool =
  let hexes = collect:
    for point, kind in l.pointData.pairs:
      if kind == Hex: {point}
  var touchedHexes: HashSet[Point2D] # Hexes that the line doesn't pass through (set is needed for jacks to work later)
  for segment in line:
    if l.pointData[segment.p1] == Hex: touchedHexes.incl segment.p1
  # For now, the level is solved if the line passes through each hex and stays on the level lines, because other symbols are not implemented yet
  return (hexes - touchedHexes).len == 0 and l.lineGoesFromStartToEnd(line)
  #TODO: implement symbols other than hexes

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
