import std/[math, sets, tables, sequtils, options, sugar]
import geometry, levels, graphs

type
  PuzzleSym = enum
    Hex, Square, Triangles, Star, Block, AntiBlock, Jack

  LineStatus* = enum
    ## This is used when adding a new point to the player's line
    None, OnlyGridNeighbors, HasDiagNeighbors, CorrectSolution, IncorrectSolution

  GameState* = object
    level*: Level
    line*: Line
    status*: LineStatus
    nxtMoves*: seq[Point2D]

  MazeRoom = object
    startCell: seq[Point2D]
    unsolvedSyms: CountTable[PuzzleSym]
    uncheckedSyms: CountTable[MazeCell]

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

proc init*(game: var GameState, levelName: string) =
  game = GameState()
  game.level = loadLevelFromFile(levelName)
  for point, kind in game.level.pointData:
    if kind == Start:
      game.nxtMoves.add point

proc addPointAndCheckResult*(game: var GameState, point: Point2D) =
  if game.line.len >= 2 and point == game.line[^2]:
    game.line.del game.line.high
  else:
    game.line &= point

  if game.line.goesFromStartToEnd(game.level):
    if game.level.checkSolution(game.line):
      game.status = CorrectSolution
    else:
      game.status = IncorrectSolution
  else:
    game.status = OnlyGridNeighbors # The added point only has horizontal and vertical neighbors
    var diagonals: seq[Point2D]
    for neighbor in game.level.pointGraph.adjList[point]:
      if not isDiagonal(neighbor - point):
        game.nxtMoves.add neighbor
      else:
        diagonals.add neighbor
        game.status = HasDiagNeighbors # The added point only has horizontal and vertical neighbors

    if game.status == HasDiagNeighbors: game.nxtMoves = diagonals

proc neighborInDirection*(game: var GameState, direction: Point2D): Option[Point2D] =
  if game.line.len > 0:
    let currPoint = game.line[^1]
    let neighbors = collect: 
      for neighbor in game.level.pointGraph.adjList[currPoint]:
        {toUnitVec(neighbor - currPoint): neighbor}
    if direction in neighbors:
      result = some(neighbors[direction])
