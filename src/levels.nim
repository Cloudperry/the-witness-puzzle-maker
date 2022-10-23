import std/[tables, sets, sequtils, options, math, strformat, sugar, algorithm]
import frosty/streams
import graphs, geometry

type
  Color* = tuple[r, g, b: int]
  PointKind* = enum ## Types of points in levels. Empty is only used as a default value.
    ## Hex is a point that requires the player to visit it, the line has to 
    ## start from a point labeled as start and end at a point labeled end.
    Empty, Start, End, Hex 
  CellKind* = enum ## Types of cells in levels. Again empty is a default value. 
    ## These are puzzle symbols that are too complicated to explain here.
    ## Most of them are explained in the project definition document.
    Empty, Square, Triangles, Star, Block, AntiBlock, Jack, ColoredJack
  MazeCell* = object
    # NIMNOTE: Here kind is one field in the object, but the other fields the
    # object has depends on the value of kind. For example squares have a color
    # field, but no shape field and Blocks have the opposite. 
    case kind*: CellKind 
    of Square, Star, ColoredJack:
      color*: Color
    of Triangles:
      count*: int
    of Block, AntiBlock:
      shape*: seq[Point2DInt] ## Polyomino shape as a collection of points.
    of Jack, Empty:                  ## (0, 0) is the top left corner of the shape.
      discard

  Level* = object
    # The below field could be used for arbitrary maze shapes
    # borderVertices*: seq[Point2D]
    # The coordinate space of the level is determined by the 2 following fields
    topLeftCorner*: Point2D
    botRightCorner*: Point2D
    pointGraph*: Graph[Point2D] ## This graph represents the points where the line can go
    cellGraph*: Graph[seq[Point2D]] ## This graph represents cells between the lines
    ## The table below contains all the non-empty points and their types 
    pointData*: Table[Point2D, PointKind] 
    ## The table below contains all the non-empty cells and their symbols 
    cellData*: Table[seq[Point2D], MazeCell]
    fgColor*: Color
    bgColor*: Color
    lineColor*: Color
  
func `==`*(c1, c2: MazeCell): bool =
  ## This comparison is needed for comparing level objects and when hashing cells
  if c1.kind == c2.kind:
    if c1.kind in {CellKind.Square, Star}:
      return c1.color == c2.color
    elif c1.kind == Triangles:
      return c1.count == c2.count
    elif c1.kind in {CellKind.Block, AntiBlock}:
      return c1.shape == c2.shape
    elif c1.kind in {CellKind.Empty, Jack}:
      return true

# --------------------------------Level creation--------------------------------
# Error handling is important to have in the level creation functions, because
# creating a level that uses the format in unintentional ways leads to weird 
# bugs in the level solution algorithm.
func cellFromCornerAndDirection*(corner, direction: Point2D): seq[Point2D] = 
  ## Creates a cell's vertices from a corner point and a vector pointing towards
  ## the opposite corner
  result = @[
    corner, corner + (direction.x, 0.0), 
    corner + (direction.x, direction.y), corner + (0.0, direction.y)
  ].sorted()
  swap(result[1], result[2])
  swap(result[^2], result[^1])

func cellFromTopLeft*(p: Point2D): seq[Point2D] = 
  ## Creates a cell's vertices from its top left corner
  cellFromCornerAndDirection(p, (1.0, 1.0))

proc makeEmptyGrid*(l: var Level; topLeftCorner, botRightCorner: Point2D) =
  ## Creates an empty grid in the point and cell graphs
  l.topLeftCorner = topLeftCorner
  l.botRightCorner = botRightCorner
  for p1 in gridPoints(topLeftCorner, botRightCorner):
    # Create nodes around a maze cell and connect them
    for p2 in [p1 + (1.0, 0.0), p1 + (0.0, 1.0)]:
      if p2.x <= botRightCorner.x and p2.y <= botRightCorner.y:
        l.pointGraph.addEdgeAndMissingNodes(p1, p2)
    # Create empty maze cells
    if p1.x in 0.0 .. botRightCorner.x - 1.0 and
    p1.y in 0.0 .. botRightCorner.y - 1.0:
      let cell = cellFromTopLeft(p1)
      l.cellGraph.addNode cell
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
      if point notin l.pointGraph: 
        raise newException(ValueError, fmt"Point {point} doesn't exist")
      else:
        l.pointData[point] = kind

proc setCellData*(l: var Level, cellData: Table[MazeCell, seq[seq[Point2D]]]) =
  for data, cells in cellData:
    for cell in cells:
      if cell notin l.cellGraph:
        raise newException(ValueError, fmt"Cell {cell} doesn't exist")
      else:
        l.cellData[cell] = data

proc setCellData*(l: var Level, cellData: Table[MazeCell, seq[Point2D]]) =
  var newCellData: Table[MazeCell, seq[seq[Point2D]]]
  for cell, points in cellData:
    for point in points:
      if cell notin newCellData:
        newCellData[cell] = @[cellFromTopLeft(point)]
      else:
        newCellData[cell].add cellFromTopLeft(point)
  l.setCellData(newCellData)

proc addConnectedPoint*(l: var Level, newPoint: Point2D, kind = PointKind.Empty,
                        connTo: varargs[Point2D]) =
  ## Adds a new point and connects it to points listed in connTo
  if newPoint in l.pointGraph:
    raise newException(ValueError, fmt"Point {newPoint} already exists")
  else:
    l.pointGraph.addNode(newPoint)
    if newPoint.x < l.topLeftCorner.x: l.topLeftCorner.x = newPoint.x
    if newPoint.y < l.topLeftCorner.y: l.topLeftCorner.y = newPoint.y
    if newPoint.x > l.botRightCorner.x: l.botRightCorner.x = newPoint.x
    if newPoint.y > l.botRightCorner.y: l.botRightCorner.y = newPoint.y
    for point in connTo:
      l.pointGraph.addEdge(newPoint, point)
    if kind != Empty: 
      l.pointData[newPoint] = kind

proc removePoint*(l: var Level, p: Point2D) =
  ## Removes a point and cleans up all the cells that had this point as a corner
  l.pointGraph.removeNode p
  l.pointData.del p
  for direction in [(1.0, 1.0), (-1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)]:
    let cell = cellFromCornerAndDirection(p, direction)
    if cell in l.cellGraph:
      l.cellGraph.removeNode cell

proc removeEdges*(l: var Level, edges: varargs[Edge[Point2D]]) = 
  ## Removes connections between points
  for edge in edges:
    l.pointGraph.removeEdge(edge.node1, edge.node2)
    if l.pointGraph.adjList[edge.node1].len == 0 or
    l.pointGraph.adjList[edge.node2].len == 0:
      raise newException(
        ValueError,
        fmt"Removing edge {edge} would leave a point without connections"
      )

proc addPointBetween*(l: var Level; p1, p2: Point2D, kind = PointKind.Empty) =
  ## Creates a new point between two points and connects the points to the new point
  let newPoint = midpoint(p1, p2)
  l.addConnectedPoint(newPoint, kind, p1, p2)
  l.pointGraph.removeEdge(p1, p2)
  l.pointGraph.addEdge(p1, newPoint)
  l.pointGraph.addEdge(p2, newPoint)

# ---------------------------Level saving and loading---------------------------
# Weird workaround used here. According to frosty examples I shouldn't need to import std/streams.
import std/streams as s
proc saveLevelToFile*(l: Level, filename: string) =
  ## Saves level object to a file
  var handle = openFileStream(filename, fmWrite)
  freeze(handle, l)
  close handle

proc loadLevelFromFile*(filename: string): Level =
  ## Loads level object from a file
  var handle = openFileStream(filename, fmRead)
  thaw(handle, result)
  close handle
