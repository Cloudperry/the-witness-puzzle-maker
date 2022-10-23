import std/[math, sets, tables, sequtils, options, sugar, strformat, algorithm]
import geometry, levels, graphs

type
  PuzzleSym = enum
    Hex, Square, Triangles, Star, Block, AntiBlock, Jack ## All the puzzle symbols

  LineStatus* = enum
    ## This is used when adding a new point to the player's line
    None, OnlyGridNeighbors, HasDiagNeighbors, CorrectSolution, IncorrectSolution

  GameState* = object
    level*: Level
    line*: Line
    linePoints: HashSet[Point2D]
    status*: LineStatus
    nxtMovesChoice*: seq[Point2D]
    nxtMovesGrid*: Table[Point2D, Point2D]
    cellEdges: HashSet[LineSegment]
    edgesOfCell: Table[seq[Point2D], HashSet[LineSegment]]

  MazeRoom = object
    startCell: seq[Point2D]
    cells: HashSet[seq[Point2D]]
    unsolvedSyms: CountTable[PuzzleSym]
    uncheckedSyms: CountTable[MazeCell]

proc init*(game: var GameState, levelName: string) =
  ## Initializes game state object so it is ready for the player's first move
  game = GameState()
  game.level = loadLevelFromFile(levelName)
  # Add start points to first turn valid moves
  for point, kind in game.level.pointData:
    if kind == Start:
      game.nxtMovesChoice.add point
  # Cache edges of cells for use by level solution algorithm
  for cell in game.level.cellGraph.nodes:
    let edges = toSetOfSegments(cell & cell[0])
    game.edgesOfCell[cell] = edges
    game.cellEdges.incl edges

func goesFromStartToEnd*(line: Line, l: Level): bool = 
  ## Checks if the line is a valid path from start to end. Only used in tests 
  ## as the game uses functions that make sure the line is valid.
  var lineHasRoute = true
  for segment in line.segments:
    if not l.pointGraph.hasRoute(segment.p1, segment.p2):
      lineHasRoute = false
  return l.pointData.getOrDefault(line[0]) == Start and 
  l.pointData.getOrDefault(line[^1]) == End and lineHasRoute

func getLineSegments*(game: GameState): HashSet[LineSegment] =
  ## Returns player line segments. Also returns 2 line segments combined into 1
  ## if there are points that are in the middle of a cell's edge.
  for i, point in game.line:
    if i >= 1:
      result.incl (game.line[i], game.line[i-1]).inAscOrder
      if i >= 2:
        let combination = combine((game.line[i-2], game.line[i-1]), 
                                  (game.line[i-1], game.line[i])).inAscOrder
        if combination in game.cellEdges:
          result.incl combination

func divideSymbolsToRooms*(game: GameState): seq[MazeRoom] =
  ## Divides the level into rooms based on the player's line. Checks triangle symbols
  ## at the same time. Combined segments mentioned above are used to make sure that the room
  ## division dfs doesn't slip through the player line when there are e.g. non-integer coordinates.
  var visited: HashSet[seq[Point2D]]
  let lineSegments = game.getLineSegments()

  func findSymsInRoom(node: seq[Point2D], room: var MazeRoom) =
    visited.incl node
    room.cells.incl node
    let nodeEdges = game.edgesOfCell[node]
    if node in game.level.cellData:
      if game.level.cellData[node].kind == Triangles:
        if (nodeEdges * lineSegments).len != game.level.cellData[node].count:
          room.unsolvedSyms.inc Triangles # Add one unsolved triangle symbol to room
      else: 
        room.uncheckedSyms.inc game.level.cellData[node] # Symbol will be checked after room division

    for neighbor in game.level.cellGraph.adjList[node]:
      if neighbor notin visited:
        let neighborEdges = game.edgesOfCell[neighbor]
        # Two maze cells have 0 sides in common with the line if they are in the same room
        if len(nodeEdges * neighborEdges * lineSegments) == 0:
          findSymsInRoom(neighbor, room)

  for cell in game.level.cellGraph.nodes:
    if cell notin visited:
      var currRoom = MazeRoom(startCell: cell)
      findSymsInRoom(cell, currRoom)
      result.add currRoom

proc findUnsolvedHexes(game: GameState, r: var MazeRoom) =
  ## Finds unsolved hexagons in a given room with a DFS. Room is given as 
  ## the starting cell used in the room division.
  var visited: HashSet[Point2D]

  proc findHexesInRoom(point: Point2D, r: var MazeRoom) =
    visited.incl point
    if game.level.pointData.getOrDefault(point) == Hex:
      r.unsolvedSyms.inc Hex
    for neighbor in game.level.pointGraph.adjList[point]:
      if neighbor notin visited and neighbor notin game.linePoints:
        findHexesInRoom(neighbor, r)

  for point in r.startCell:
    if point notin game.linePoints:
      findHexesInRoom(point, r)
      break

func checkSolution*(game: GameState): bool =
  ## Checks if the player line is a correct solution. First step is room division,
  ## second step is checking hexes and the rest of the symbols are checked based
  ## on room division results.
  var rooms = game.divideSymbolsToRooms()
  for room in rooms.mitems:
    game.findUnsolvedHexes(room)
    var squares, stars: CountTable[Color]
    for symbol, count in room.uncheckedSyms:
      if symbol.kind == Square:
        squares.inc(symbol.color, count) 
      elif symbol.kind == Star:
        stars.inc(symbol.color, count) 
    # Count unsolved squares
    if squares.len > 1:
      debugEcho squares.values.toSeq()
      room.unsolvedSyms[Square] = squares.values.toSeq().sorted()[0..^2].sum()
    # Count unsolved stars
    for color, count in stars:
      let squareCount = squares[color]
      if squareCount notin {0, 1} or (count + squareCount) != 2:
        # 2 stars are paired and the rest are not, if there is one star abs() will make this 1
        room.unsolvedSyms[Star] = abs(count - 2) 
    # Fix unsolved symbols if there are jacks
    let unsolvedSymsAfterJacks = room.unsolvedSyms.values.toSeq().sum() -
                                 room.uncheckedSyms[MazeCell(kind: Jack)]
    if unsolvedSymsAfterJacks != 0:
      # Not all unsolved symbols could be fixed by jacks or not all jacks were used
      when defined(printReasonNotSolved):
        debugEcho fmt"room {room.cells} unsolved symbols {room.unsolvedSyms}" & 
                  fmt", jacks {room.uncheckedSyms[MazeCell(kind: Jack)]}"
      return false
  return true
  #TODO: Implement blocks (polyominos)

proc addPointAndCheckResult*(game: var GameState, point: Point2D) =
  ## Adds a point to the player line and updates valid next moves in game state.
  ## This function assumes that only correct points from game state's next moves are given.
  if game.line.len >= 2 and point == game.line[^2]:
    game.linePoints.excl game.line[^1]
    game.line.del game.line.high
  else:
    game.linePoints.incl point
    game.line.add point

  if game.line.goesFromStartToEnd(game.level):
    if game.checkSolution():
      game.status = CorrectSolution
    else:
      game.status = IncorrectSolution
  else:
    game.nxtMovesGrid.clear
    game.nxtMovesChoice.setLen 0
    game.status = OnlyGridNeighbors # The added point only has horizontal and vertical neighbors
    for neighbor in game.level.pointGraph.adjList[point]:
      if game.line.len == 1 or neighbor == game.line[^2] or
      neighbor notin game.linePoints: # Check if the point is a valid move
        if not isDiagonal(neighbor - point):
          game.nxtMovesGrid[toUnitVec(neighbor - point)] = neighbor
        else:
          game.nxtMovesChoice.add neighbor
          game.status = HasDiagNeighbors # The added point has diagonal neighbors

proc neighborInDirection*(game: var GameState, 
                          direction: Point2D): Option[Point2D] =
  ## This function returns the neighboring point in the maze in a given direction
  ## if it is a valid move
  if game.line.len > 0:
    if direction in game.nxtMovesGrid:
      return some game.nxtMovesGrid[direction]

proc setLine*(game: var GameState, line: Line) =
  ## For testing use only. This function assumes that the line follows the rules of the game.
  game.line = line
  game.linePoints = line.toHashSet()
