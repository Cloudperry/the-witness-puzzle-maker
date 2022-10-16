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
    of Jack, Empty:                     ## (0, 0) is the top left corner of the shape.
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

# I had to manually implement this comparison, because Nim's case objects don't support it by default.
# Case objects are like sum types in other languages. This enables setPointData and setCellData to work.
proc `==`*(c1, c2: MazeCell): bool =
  if c1.kind == c2.kind:
    if c1.kind in {Square, Star}:
      return c1.color == c2.color
    elif c1.kind == Triangles:
      return c1.count == c2.count
    elif c1.kind in {Block, AntiBlock}:
      return c1.shape == c2.shape
  return false # False would be returned by default, but I wanted to make it explicit

proc cellFromTopLeft*(p: Point2D): seq[Point2D] = 
  @[p, p + (1.0, 0.0), p + (1.0, 1.0), p + (0.0, 1.0)]

proc makeEmptyGrid*(l: var Level; topLeftCorner, botRightCorner: Point2D) =
  l.topLeftCorner = topLeftCorner
  l.botRightCorner = botRightCorner
  for p1 in gridPoints(topLeftCorner, botRightCorner):
    # Create lines around a maze cell
    l.pointData[p1] = Empty
    for p2 in [p1 + (1.0, 0.0), p1 + (0.0, 1.0)]:
      if p2.x <= botRightCorner.x and p2.y <= botRightCorner.y:
        l.pointGraph.addEdgeAndMissingNodes(p1, p2)
    # Create empty maze cells
    if p1.x in 0.0 .. botRightCorner.x and p1.y in 0.0 .. botRightCorner.y:
      let cell = cellFromTopLeft(p1)
      l.cellGraph.addNode cell
      l.cellData[cell] = MazeCell(kind: Empty)
  # Connect all the adjacent cells together in the graph
  for cell in l.cellGraph.nodes:
    let cellToRight = cell.mapIt(it + (1.0, 0.0))
    let cellBelow = cell.mapIt(it + (0.0, 1.0))
    if cellToRight in l.cellGraph:
      l.cellGraph.addEdge(cell, cellToRight)
    if cellBelow in l.cellGraph:
      l.cellGraph.addEdge(cell, cellBelow)

proc setPointData*(l: var Level, pointData: Table[PointKind, seq[Point2D]]) = 
  for kind, points in pointData:
    for point in points:
      # Could be changed to an error if the point doesn't already exist (new points should be made with addConnectedPoint)
      if point in l.pointGraph: 
        l.pointData[point] = kind

proc setCellData*(l: var Level, cellData: Table[MazeCell, seq[seq[Point2D]]]) =
  for data, cells in cellData:
    for cell in cells:
      if cell in l.cellGraph:
        l.cellData[cell] = data

proc removePoint*(l: var Level, p: Point2D) =
  l.pointGraph.removeNode(p)
  l.pointData.del p

proc addConnectedPoint*(l: var Level, kind: PointKind, newPoint: Point2D,
                        connectedTo: varargs[Point2D]) =
  l.pointGraph.addNode(newPoint)
  if newPoint.x < l.topLeftCorner.x: l.topLeftCorner.x = newPoint.x
  if newPoint.y < l.topLeftCorner.y: l.topLeftCorner.y = newPoint.y
  if newPoint.x > l.botRightCorner.x: l.botRightCorner.x = newPoint.x
  if newPoint.y > l.botRightCorner.y: l.botRightCorner.y = newPoint.y
  for point in connectedTo:
    l.pointGraph.addEdge(newPoint, point)
  l.pointData[newPoint] = kind

proc removeEdges*(l: var Level, edges: varargs[tuple[p1, p2: Point2D]]) = 
  for edge in edges:
    l.pointGraph.removeEdge(edge.p1, edge.p2)

proc addPointBetween*(l: var Level, kind: PointKind, p1, p2: Point2D) =
  l.addConnectedPoint(kind, midpoint(p1, p2), p1, p2)

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
