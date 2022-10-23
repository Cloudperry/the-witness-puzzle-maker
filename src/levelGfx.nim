import std/[math, lenientops, tables, sets]
import nimraylib_now
import levels, graphs, geometry

converter vec2ToRaylibVec(v: Vec2): Vector2 = Vector2(x: v.x.cfloat, y: v.y.cfloat)

type
  DrawOptions* = object
    ## This object will be used to store graphics parameters that shouldn't be part of the level
    winSize*: tuple[w, h: int]
    shorterWinDimension: int
    centerPoint*: Point2DInt ## Point on the screen where the center of the maze should be
    insidePanelMargin* = 0.5
    outsidePanelMargin* = 1.0
    borderWidth* = 0.25
    lineWidth* = 0.125
    hexRadius* = 0.06
    jackRadius* = 0.125
    jackWidth* = 0.06
    startRadius* = 0.2
    triangleRadius* = 0.1
    squareLength* = 0.25
    starLength* = 0.2
    borderColor* = (140, 140, 155)
    jackColor* = (240, 240, 240)
    bgColor* = (80, 80, 80)
  DrawableLevel* = object
    topLeft*, botRight*, size: Point2D
    gfxData*: LevelGfxData
  LevelGfxData = object 
    ## This object is used to store pixel coordinates for the level.
    ## It is used when drawing the level
    lineSegments: seq[tuple[p1, p2: Point2DInt]]
    startingPoints: seq[Point2DInt]
    endindgPoints: seq[Point2DInt]
    bgRect: tuple[topLeftCorner, size: Point2DInt]
    squareLength, starLength, lineWidth, jackWidth: float
    startRadius, hexRadius, triangleRadius: float
    hexes: seq[Point2D]
    jackTopDeltaVec, jackLeftDeltaVec, jackRightDeltaVec: Point2D
    squares: seq[tuple[pos: Point2DInt, color: levels.Color]]
    stars: seq[tuple[pos: Point2DInt, color: levels.Color]]
    triangles: seq[Point2D]
    jacks: seq[Point2D]

func setPositionDefaults*(opts: var DrawOptions, winSize: tuple[w, h: int]) = 
    opts.winSize = winSize
    opts.shorterWinDimension = min(winSize.w, winSize.h)
    opts.centerPoint = (winSize.w div 2, winSize.h div 2)

func mazeDistToScreen*(d: DrawableLevel, dist: float, o: DrawOptions): int =
  if o.winSize.w == o.shorterWinDimension:
    result = toInt(o.shorterWinDimension * (dist / d.size.x))
  else:
    result = toInt(o.shorterWinDimension * (dist / d.size.y))

proc mazePosToScreen*(d: DrawableLevel, p: Point2D, o: DrawOptions): Point2DInt =
  # Transforms maze coordinates to screen pixel coordinates
  let panelCenter = midpoint(d.topLeft, d.botRight)
  # Variable below is a vector for how long the distance on each axis is relative to the entire
  # coordinate space. For example point (1, 1) in a coordinate space from 0 to 4 on both axes
  # would get a relative delta of (-1/4, -1/4), because it is one fourth of the coordinate space length
  # away from the center (2, 2) in both directions.
  let relativeDeltaFromCenter = (p - panelCenter) / d.size 
  result = o.centerPoint + (relativeDeltaFromCenter * o.shorterWinDimension).toInt()

proc calcGfxData(l: Level, d: DrawableLevel, o: DrawOptions): LevelGfxData =
  #TODO: Make macros? for the most repetitive parts of this function
  # Calculate sizes for symbols and maze elements
  result.lineWidth = d.mazeDistToScreen(o.lineWidth, o).float 
  result.startRadius = d.mazeDistToScreen(o.startRadius, o).float
  result.hexRadius = d.mazeDistToScreen(o.hexRadius, o).float
  result.squareLength = d.mazeDistToScreen(o.squareLength, o).float
  result.starLength = d.mazeDistToScreen(o.starLength, o).float
  result.triangleRadius = d.mazeDistToScreen(o.triangleRadius, o).float
  result.jackWidth = d.mazeDistToScreen(o.jackWidth, o).float
  # Calculate screen positions for puzzle symbols
  for edge in l.pointGraph.getEdges():
    result.lineSegments.add (d.mazePosToScreen(edge.node1, o),
                             d.mazePosToScreen(edge.node2, o))
  let bgRectTopLeft = l.topLeftCorner - o.insidePanelMargin
  let bgRectBotRight = l.botRightCorner + o.insidePanelMargin
  result.bgRect = (
    d.mazePosToScreen(bgRectTopLeft, o),
    d.mazePosToScreen(bgRectBotRight, o) -
    d.mazePosToScreen(bgRectTopLeft, o)
  )
  for point, symbol in l.pointData.pairs:
    case symbol
    of Start:
      result.startingPoints.add d.mazePosToScreen(point, o) 
    of Hex:
      result.hexes.add d.mazePosToScreen(point, o).toFloat()
    else:
      discard
  for cell, symbol in l.cellData.pairs:
    let cellCenter = midpoint(cell)
    let cellScreenCenter = d.mazePosToScreen(cellCenter, o)
    case symbol.kind
    of Square:
      let rectPos = d.mazePosToScreen(cellCenter - (o.squareLength / 2), o)
      result.squares.add (rectPos, symbol.color)
    of Star:
      result.stars.add (cellScreenCenter, symbol.color)
    of Jack:
      let jackRadius = d.mazeDistToScreen(o.jackRadius, o).float
      result.jackTopDeltaVec = (0.0, -1.0) * jackRadius
      result.jackLeftDeltaVec = rotateAroundOrigin(result.jackTopDeltaVec,
                                                   -2 * PI / 3)
      result.jackRightDeltaVec = rotateAroundOrigin(result.jackLeftDeltaVec,
                                                   -2 * PI / 3)

      result.jacks.add cellScreenCenter.toFloat
    of Triangles:
      if symbol.count in {1, 3}:
        result.triangles.add cellScreenCenter.toFloat()
      if symbol.count == 3:
        result.triangles.add (cellScreenCenter.x.float - 2 * result.triangleRadius, cellScreenCenter.y.float)
        result.triangles.add (cellScreenCenter.x.float + 2 * result.triangleRadius, cellScreenCenter.y.float)
      if symbol.count == 2:
        result.triangles.add (cellScreenCenter.x.float - result.triangleRadius, cellScreenCenter.y.float)
        result.triangles.add (cellScreenCenter.x.float + result.triangleRadius, cellScreenCenter.y.float)
    else:
      discard
  #TODO: Add blocks (tetris pieces)

proc getDrawableLevel*(l: Level, o: DrawOptions): DrawableLevel =
  let totalMargin = o.insidePanelMargin + o.borderWidth + o.outsidePanelMargin
  let totalMarginVec = (totalMargin, totalMargin)
  result.topLeft = (l.topLeftCorner - totalMarginVec)
  result.botRight = (l.botRightCorner + totalMarginVec)
  result.size = result.botRight - result.topLeft
  result.gfxData = l.calcGfxData(result, o)

proc squareToRect(pos: Point2DInt, length: float): Rectangle = 
  Rectangle(x: pos.x.float, y: pos.y.float, width: length, height: length)

proc drawLineRoundedEnds(startPos, endPos: Vec2; thickness: float, 
                         color: raylib.Color) =
  drawLineEx(startPos, endPos, thickness, color)
  drawCircle(startPos.x.int, startPos.y.int, thickness / 2, color)
  drawCircle(endPos.x.int, endPos.y.int, thickness / 2, color)

proc draw*(l: Level, v: LevelGfxData, o: DrawOptions) = 
  drawRectangleV(v.bgRect[0], v.bgRect[1], l.bgColor)
  for line in v.lineSegments:
    drawLineRoundedEnds(line.p1, line.p2, v.lineWidth, l.fgColor)
  for point in v.startingPoints:
    drawCircle(point.x, point.y, v.startRadius, l.fgColor)
  for square in v.squares:
    let rect = squareToRect(square.pos, v.squareLength)
    drawRectangleRounded(rect, 0.5, 10, square.color)
  for star in v.stars:
    let rect = squareToRect(star.pos, v.starLength)
    drawRectanglePro(rect, (rect.width, rect.height) / 2, 0.0, star.color)
    drawRectanglePro(rect, (rect.width, rect.height) / 2, 45.0, star.color)
  for hex in v.hexes:
    drawPoly(hex, 6, v.hexRadius, 0.0, (0, 0, 0))
  for triangle in v.triangles:
    drawPoly(triangle, 3, v.triangleRadius, 180.0, (255, 120, 0))
  for jack in v.jacks:
    drawLineEx(jack, jack + v.jackTopDeltaVec, v.jackWidth, o.jackColor)
    drawLineEx(jack, jack + v.jackLeftDeltaVec, v.jackWidth, o.jackColor)
    drawLineEx(jack, jack + v.jackRightDeltaVec, v.jackWidth, o.jackColor)
  #TODO: Add block symbol drawing, maze borders, player line and rounded lines

proc drawPlayerLine*(line: Line, l: Level, d: DrawableLevel, o: DrawOptions) =
  let lineStartScreen = d.mazePosToScreen(line[0], o)
  drawCircle(lineStartScreen.x, lineStartScreen.y, d.gfxData.startRadius, l.lineColor)
  for segment in line.segments:
    let segmentScreenPos: LineSegment = (
      d.mazePosToScreen(segment.p1, o).toFloat, 
      d.mazePosToScreen(segment.p2, o).toFloat
    )
    drawLineRoundedEnds(segmentScreenPos.p1, segmentScreenPos.p2, d.gfxData.lineWidth, l.lineColor)
