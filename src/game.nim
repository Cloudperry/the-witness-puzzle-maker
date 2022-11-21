import std/[math, sets, tables, sequtils, options, sugar, algorithm]
import geometry, levels, graphs

type
  PuzzleSym = enum
    ## All the puzzle symbols
    Hex, Square, Triangles, Star, Block, AntiBlock, Jack, ColoredJack 

  LineStatus* = enum
    ## This status is returned when the player makes a move (adds a point to the line).
    ## OnlyGridNeighbors and HasDiagNeighbors are related to the current control scheme
    ## using arrow keys for movement when all the neighbors are on integer grid coordinates.
    ## They could be replaced by one enum that tells the solution is in progress, if 
    ## the line was controlled by mouse.
    None, OnlyGridNeighbors, HasDiagNeighbors, CorrectSolution, IncorrectSolution

  GameState* = object
    ## These fields are used by the game ui/implementation when playing the game
    level*: Level
    line*: Line
    status*: LineStatus
    nxtMovesChoice*: seq[Point2D]
    nxtMovesGrid*: Table[Point2D, Point2D]
    ## These private fields are only used by the level solution algorithm
    linePoints: HashSet[Point2D]
    cellEdges: HashSet[LineSegment]
    edgesOfCell: Table[seq[Point2D], HashSet[LineSegment]]
  
  MazeRoom = object
    ## This object stores the results of room division and is used while checking the solution
    startCell: seq[Point2D] ## Cell where the room division DFS started
    unsolvedSyms: CountTable[PuzzleSym]
    uncheckedSyms: CountTable[MazeCell]
    hasBlocks: bool
    rectCells: seq[Point2DInt] ## This will only be used if the room has blocks
    topLeft, botRight: Point2DInt

proc init*(game: var GameState, level: sink Level) =
  ## Initializes game state object so it is ready for the player's first move
  game = GameState(level: level)
  # Add start points to first turn valid moves
  for point, kind in game.level.pointData:
    if kind == Start:
      game.nxtMovesChoice.add point
  # Cache edges of cells for use by level solution algorithm
  for cell in game.level.cellGraph.nodes:
    let edges = toSetOfSegments(cell & cell[0])
    game.edgesOfCell[cell] = edges
    game.cellEdges.incl edges

proc init*(game: var GameState, levelName: string) = 
  game.init loadLevelFromFile(levelName)

func goesFromStartToEnd*(line: Line, level: Level): bool = 
  ## Checks if the line is a valid path from start to end. Only used in tests 
  ## as the game uses functions that make sure the line is valid.
  var lineHasRoute = true
  for segment in line.segments:
    if not level.pointGraph.hasRoute(segment.p1, segment.p2):
      lineHasRoute = false
  return level.pointData.getOrDefault(line[0]) == Start and 
  level.pointData.getOrDefault(line[^1]) == End and lineHasRoute

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

proc getUnsolvedHexes(game: GameState): HashSet[Point2D] =
  result = collect:
    for point, kind in game.level.pointData:
      if kind == Hex and point notin game.linePoints:
        {point}

func divideToRoomsAndCheckSyms*(game: GameState): seq[MazeRoom] =
  ## Divides the level into rooms based on the player's line. Checks triangle and hex symbols
  ## at the same time. Combined segments mentioned above are used to make sure that the room
  ## division dfs doesn't slip through the player line when there are e.g. non-integer coordinates.
  var visited: HashSet[seq[Point2D]]
  let lineSegments = game.getLineSegments()
  let unsolvedHexes = game.getUnsolvedHexes()

  func findSymsInRoom(node: seq[Point2D], room: var MazeRoom) =
    visited.incl node
    if node.len == 4: 
      room.rectCells.add [node[0].toInt]
    # Check if there are unsolved hexes in the room
    if unsolvedHexes.len > 0:
      for point in node:
        if point in unsolvedHexes:
          room.unsolvedSyms.inc Hex

    let nodeEdges = game.edgesOfCell[node]
    if node in game.level.cellData:
      if game.level.cellData[node].kind == Triangles:
        if (nodeEdges * lineSegments).len != game.level.cellData[node].count:
          room.unsolvedSyms.inc Triangles # Add one unsolved triangle symbol to room
      else: 
        room.uncheckedSyms.inc game.level.cellData[node] # Symbol will be checked after room division
        if game.level.cellData[node].kind == Block: 
          room.hasBlocks = true

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

type
  ColToRows = Table[Point2DInt, HashSet[int]]
  RowToCols = Table[int, seq[Point2DInt]]
  Placement = object
    blockShape: seq[Point2DInt] # Which block shape was used
    placement: seq[Point2DInt]  # Where it was placed (which coordinates it covers)

proc getAllBlockPlacements(room: MazeRoom, blocks: CountTable[seq[Point2DInt]]): seq[Placement] =
  ## Generates all possible block placements. Placement object contains 
  ## the block shape that was placed and where it was placed.
  for blk, count in blocks:
    for pos in room.rectCells:
      var blockInCell: seq[Point2DInt]
      var blockFits = true
      for rectPos in blk:
        if rectPos + pos in room.rectCells:
          blockInCell.add rectPos + pos
        else:
          blockFits = false
          break
      if blockFits:
        result.add Placement(blockShape: blk, placement: blockInCell.sorted()).repeat(count)

proc select(ctr: var ColToRows, rtc: var RowToCols,
            row: int): seq[HashSet[int]] =
  ## Used by Algorithm X to select a row
  for col1 in rtc[row]:
    for rowOnCol1 in ctr[col1]:
      for col2 in rtc[rowOnCol1]:
        if col2 != col1:
          ctr[col2].excl rowOnCol1
    var cols: HashSet[int]
    if ctr.pop(col1, cols):
      result.add cols

proc deselect(ctr: var ColToRows, rtc: var RowToCols, row: int, 
              rows: var seq[HashSet[int]]) =
  ## Used by Algorithm X to deselect a row
  for col1 in reversed(rtc[row]):
    ctr[col1] = rows.pop
    for rowOnCol1 in ctr[col1]:
      for col2 in rtc[rowOnCol1]:
        if col2 != col1:
          ctr[col2].incl rowOnCol1

iterator findCovers(ctr: var ColToRows, rtc: var Table[int, seq[Point2DInt]], 
                    solution: seq[int] = @[]): seq[int] {.closure.} =
  ## This function solves the exact cover problem by using Knuth's Algorithm X
  # This implementation uses hash tables instead of a dancing links matrix. Read
  # the implementation document to find out what this implementation is based on.
  if ctr.len == 0:
    yield solution
  else:
    var nextCol: Point2DInt
    var nextColRows = int.high
    for col, rows in ctr:
      if rows.len < nextColRows:
        nextColRows = rows.len
        nextCol = col

    for row in ctr[nextCol]:
      var solution = solution & row
      var rows = select(ctr, rtc, row)
      for cover in findCovers(ctr, rtc, solution):
        yield cover
      deselect(ctr, rtc, row, rows)
      solution.del solution.high

func toAlgoXProblemMat(placements: seq[Placement]): tuple[ctr: ColToRows,
                                                          rtc: RowToCols] =
  ## Converts block placements to an Algorithm X problem matrix
  for rowN, placement in placements:
    result.rtc[rowN] = placement.placement
    for pos in placement.placement:
      if pos notin result.ctr:
        result.ctr[pos] = toHashSet([rowN])
      else: 
        result.ctr[pos].incl rowN

func checkSolution*(game: GameState): bool =
  ## Checks if the player line is a correct solution.
  # This is a 6 step process:
  # 1. Room division that checks hexes and triangles (all following steps use results of this)
  # 2. Check rectangles based on per-room rectangle counts for each color
  # 3. Check stars in room based on number of stars and rectangles of each color
  # 4. Check blocks in room by using algorithm x
  # 5. Cancel unsolved symbols if there are jacks in the room
  # 6. Level is solved if there are no symbols left unsolved and no unused jacks
  var rooms = game.divideToRoomsAndCheckSyms()
  for room in rooms.mitems:
    var squares, stars: CountTable[Color]
    for symbol, count in room.uncheckedSyms:
      if symbol.kind == Square:
        squares.inc(symbol.color, count) 
      elif symbol.kind == Star:
        stars.inc(symbol.color, count) 
    # Count unsolved squares
    if squares.len > 1:
      room.unsolvedSyms[Square] = squares.values.toSeq().sorted()[0..^2].sum()
    # Count unsolved stars
    for color, count in stars:
      let squareCount = squares[color]
      if squareCount notin {0, 1} or (count + squareCount) != 2:
        # 2 stars are paired and the rest are not, if there is one star abs() will make this 1
        room.unsolvedSyms[Star] = abs(count - 2) 
    if room.hasBlocks:
      # Collect counts for each of the block shapes
      var blocks: CountTable[seq[Point2DInt]]
      for sym, count in room.uncheckedSyms:
        if sym.kind == Block:
          blocks.inc(sym.shape, count) 

      # Set up Algorithm X problem matrix
      let placements = room.getAllBlockPlacements(blocks)
      var (ctr, rtc) = placements.toAlgoXProblemMat()
      
      # Iterate over covers given by Algo X (only covers that don't use a single block twice are accepted)
      var foundSolution = false
      for solution in findCovers(ctr, rtc):
        var blocksInSolution: CountTable[seq[Point2DInt]]
        for i in solution:
          blocksInSolution.inc placements[i].blockShape
        if blocksInSolution == blocks: 
          foundSolution = true
          break
      if not foundSolution: 
        #TODO: Implement a way to count unsolved blocks, so that blocks work together with jacks.
        # Now all the blocks in the room are counted as unsolved.
        room.unsolvedSyms[Block] = blocks.values.toSeq().sum()

    # Cancel unsolved symbols if there are jacks
    let unsolvedSymsAfterJacks = room.unsolvedSyms.values.toSeq().sum() -
                                 room.uncheckedSyms[MazeCell(kind: Jack)]
    if unsolvedSymsAfterJacks != 0:
      # Not all unsolved symbols could be canceled by jacks or not all jacks were used
      when defined(printReasonNotSolved):
        debugEcho fmt"room {room.startCell} unsolved symbols {room.unsolvedSyms}" & 
                  fmt", jacks {room.uncheckedSyms[MazeCell(kind: Jack)]}"
      return false

  return true

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
