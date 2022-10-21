import std/[tables, sets, sequtils, options, math, strformat, sugar, algorithm]
import frosty/streams
import graphs, geometry

type
  Color* = tuple[r, g, b: int]
  PointKind* = enum ## All the puzzle symbols that can be attached to a point
    Empty, Start, End, Hex
  CellKind* = enum ## All the puzzle symbols that can be attached to a cell
    Empty, Square, Triangles, Star, Block, AntiBlock, Jack
  PuzzleSym = enum
    Hex, Square, Triangles, Star, Block, AntiBlock, Jack
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
    of Jack, Empty:                  ## (0, 0) is the top left corner of the shape.
      discard

  PointAddResult* = enum
    ## This is used when adding a new point to the player's line
    None, Invalid, Valid, CorrectSolution, IncorrectSolution
    
  Level* = object
    # The below field could be used for arbitrary maze shapes
    # borderVertices*: seq[Point2D]
    # The coordinate space of the level is determined by the 2 following fields
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

  MazeRoom = object
    startCell: seq[Point2D]
    unsolvedSyms: CountTable[PuzzleSym]
    uncheckedSyms: CountTable[MazeCell]
  
func `==`*(c1, c2: MazeCell): bool =
  ## This comparison is needed for comparing level objects and when hashing cells
  if c1.kind == c2.kind:
    if c1.kind in {Square, Star}:
      return c1.color == c2.color
    elif c1.kind == Triangles:
      return c1.count == c2.count
    elif c1.kind in {Block, AntiBlock}:
      return c1.shape == c2.shape
    elif c1.kind in {CellKind.Empty, Jack}:
      return true

# --------------------------------Level creation--------------------------------
# Error handling is important to have in the level creation functions, because
# creating a level that uses the format in unintentional ways leads to weird bugs. 
func cellFromCornerAndDirection*(corner, direction: Point2D): seq[Point2D] = 
  result = @[
    corner, corner + (direction.x, 0.0), 
    corner + (direction.x, direction.y), corner + (0.0, direction.y)
  ].sorted()
  swap(result[1], result[2])
  swap(result[^2], result[^1])

func cellFromTopLeft*(p: Point2D): seq[Point2D] = 
  cellFromCornerAndDirection(p, (1.0, 1.0))

proc makeEmptyGrid*(l: var Level; topLeftCorner, botRightCorner: Point2D) =
  l.topLeftCorner = topLeftCorner
  l.botRightCorner = botRightCorner
  for p1 in gridPoints(topLeftCorner, botRightCorner):
    # Create lines around a maze cell
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

proc addConnectedPoint*(l: var Level, newPoint: Point2D, kind = Empty,
                        connTo: varargs[Point2D]) =
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
  l.pointGraph.removeNode p
  l.pointData.del p
  for direction in [(1.0, 1.0), (-1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)]:
    let cell = cellFromCornerAndDirection(p, direction)
    if cell in l.cellGraph:
      l.cellGraph.removeNode cell

proc removeEdges*(l: var Level, edges: varargs[Edge[Point2D]]) = 
  for edge in edges:
    l.pointGraph.removeEdge(edge.node1, edge.node2)
    if l.pointGraph.adjList[edge.node1].len == 0 or
    l.pointGraph.adjList[edge.node2].len == 0:
      raise newException(
        ValueError,
        fmt"Removing edge {edge} would leave a point without connections"
      )

proc addPointBetween*(l: var Level; p1, p2: Point2D, kind = Empty) =
  let newPoint = midpoint(p1, p2)
  l.addConnectedPoint(newPoint, kind, p1, p2)
  l.pointGraph.removeEdge(p1, p2)
  l.pointGraph.addEdge(p1, newPoint)
  l.pointGraph.addEdge(p2, newPoint)

# ---------------------------Level saving and loading---------------------------
# Weird workaround used here. According to frosty examples I shouldn't need to import std/streams.
import std/streams as s
proc saveLevelToFile*(l: Level, filename: string) =
  ## Saves level object to a file.
  var handle = openFileStream(filename, fmWrite)
  freeze(handle, l)
  close handle

proc loadLevelFromFile*(filename: string): Level =
  ## Loads level object from a file.
  var handle = openFileStream(filename, fmRead)
  thaw(handle, result)
  close handle

# --------------------------------Game mechanics--------------------------------
func goesFromStartToEnd*(line: Line, l: Level): bool = 
  var lineHasRoute = true
  for segment in line.segments:
    if not l.pointGraph.hasRoute(segment.p1, segment.p2):
      lineHasRoute = false
  return l.pointData.getOrDefault(line[0]) == Start and 
  l.pointData.getOrDefault(line[^1]) == End and lineHasRoute

func divideSymbolsToRooms*(level: Level, line: Line): seq[MazeRoom] =
  ## Divides the level into rooms based on the player's line. Checks triangle symbols
  ## at the same time, because all the relevant information is available here.
  let lineSegments = line.toSetOfSegments()
  var visited: HashSet[seq[Point2D]]

  func findSymsInRoom(node: seq[Point2D], room: var MazeRoom) =
    visited.incl node
    let nodeSegments = toSetOfSegments(node & node[0])
    if node in level.cellData:
      if level.cellData[node].kind == Triangles:
        if (nodeSegments * lineSegments).len != level.cellData[node].count:
          room.unsolvedSyms.inc Triangles # Add one unsolved triangle symbol to room
      else: 
        # This symbol will be checked after the room division is done
        room.uncheckedSyms.inc level.cellData[node] 

    for neighbor in level.cellGraph.adjList[node]:
      if neighbor notin visited:
        let neighborSegments = toSetOfSegments(neighbor & neighbor[0])
        # Two non-overlapping polygons have 0 sides in common with the line if they are in the same room
        if len(nodeSegments * neighborSegments * lineSegments) == 0:
          findSymsInRoom(neighbor, room)

  for cell in level.cellGraph.nodes:
    if cell notin visited:
      var currRoom = MazeRoom(startCell: cell)
      findSymsInRoom(cell, currRoom)
      result.add currRoom

proc findUnsolvedHexes(level: Level, line: Line, r: var MazeRoom) =
  ## Finds unsolved hexagons in a given room with a DFS. Room is given as 
  ## a cell by the room division of the previous function.
  var visited: HashSet[Point2D]
  let linePoints = line.toHashSet()

  proc findHexesInRoom(point: Point2D, r: var MazeRoom) =
    visited.incl point
    if level.pointData.getOrDefault(point) == Hex:
      r.unsolvedSyms.inc Hex
    for neighbor in level.pointGraph.adjList[point]:
      if neighbor notin visited and neighbor notin linePoints:
        findHexesInRoom(neighbor, r)

  for point in r.startCell:
    if point notin linePoints:
      findHexesInRoom(point, r)
      break

func checkSolution*(level: Level, line: Line): bool =
  var rooms = level.divideSymbolsToRooms(line)
  for room in rooms.mitems:
    level.findUnsolvedHexes(line, room)
    var squares, stars: CountTable[Color]
    for symbol, count in room.uncheckedSyms:
      if symbol.kind == Square:
        squares.inc(symbol.color, count) 
      elif symbol.kind == Star:
        stars.inc(symbol.color, count) 
    # Find unsolved squares
    if squares.len > 1:
      squares.sort()
      room.unsolvedSyms[Square] = squares.values.toSeq()[1..^1].sum()
    # Find unsolved stars
    for color, count in stars:
      let squareCount = squares[color]
      if squareCount notin {0, 1} or (count + squareCount) mod 2 != 0:
        room.unsolvedSyms[Star] = count
    # Fix unsolved symbols if there are jacks
    let unsolvedSymsAfterJacks = room.unsolvedSyms.values.toSeq().sum() - room.uncheckedSyms[MazeCell(kind: Jack)] 
    if unsolvedSymsAfterJacks != 0:
      # Not all unsolved symbols could be fixed by jacks or not all jacks were used
      when defined(printReasonNotSolved):
        debugEcho fmt"room {room.startCell} unsolved symbols {room.unsolvedSyms}, jacks {room.uncheckedSyms[MazeCell(kind: Jack)]}"
      return false
  return true
  #TODO: Implement blocks (polyominos)

proc checkAndAddPoint*(line: var Line, point: Point2D, 
                      level: Level): PointAddResult =
  if line.len == 0:
    if level.pointData.getOrDefault(point) != Start:
      return Invalid
    else:
      line &= point
      return Valid
  else:
    let eraseLast = line.len >= 2 and point == line[^2]
    if point notin level.pointGraph.adjList[line[^1]] or 
    (not eraseLast and point in line):
      return Invalid
    elif eraseLast:
      line.del line.high
    else:
      line &= point
      if line.goesFromStartToEnd(level):
        if level.checkSolution(line):
          return CorrectSolution
        else:
          return IncorrectSolution
      return Valid

func pointInDirection*(line: Line, direction: Point2D, level: Level): Option[Point2D] =
  if line.len > 0:
    let currPoint = line[^1]
    proc toDirectionUnitVec(point: Vec2): Point2D =
      toUnitVec(point - currPoint)
    let neighbors = collect: 
      for neighbor in level.pointGraph.adjList[currPoint]:
        {neighbor.toDirectionUnitVec: neighbor}
    if direction in neighbors:
      result = some(neighbors[direction])
