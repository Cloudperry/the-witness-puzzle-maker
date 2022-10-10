import std/[math, lenientops, tables, sets]
import nimraylib_now
import levels, graphs
# If you are about to read the code in this module then pls don't. Its a 
# horrible hacked together mess with bad names. I will refactor it to be much
# smaller tomorrow and add the rest of the missing symbols to the renderer.
# All you need to know about this module is that it is used to scale a level 
# to arbitrary screen resolutions and draw it. It already works very well, but
# the code is just extremely convoluted.

const
  #TODO: Maybe change line thickness and start radius to use level space coordinates instead of raw pixels
  borderWidth = 0.25
  lineWidth = 0.125
  hexRadius = 0.06
  startRadius = 0.2
  triangleRadius = 0.1
  squareWidth = 0.3
  insidePanelMargin = 0.5
  outsidePanelMargin = 1.0
  defaultBorderColor = (140, 140, 155) # Maybe border color should be themeable by the level
  defaultBgColor = (80, 80, 80)

converter vec2ToRaylibVec(v: Vec2): Vector2 = Vector2(x: v.x.cfloat, y: v.y.cfloat)

type
  LineSeq* = seq[tuple[p1, p2: Point2DInt]]
  DrawOptions* = object
    ## This object will be used to store graphics parameters that shouldn't be part of the level
    winSize*: tuple[w, h: int]
    shorterWinDimension: int
    centerPoint*: Point2DInt ## Point on the screen where the center of the maze should be
    borderColor* = defaultBorderColor
    bgColor* = defaultBgColor
  DrawCoordSpace* = object
    topLeft, botRight: Point2D
    w, h: float
  LevelGfxData* = object 
    ## This object is used to store pixel coordinates for the level.
    ## It is used when drawing the level
    lineSegments: LineSeq
    startingPoints: seq[Point2DInt]
    bgRect: tuple[topLeftCorner, size: Point2DInt]
    startRadius, lineWidth, hexRadius, triangleRadius: float
    hexes: seq[Point2D]
    squares: seq[tuple[rect: Rectangle, color: levels.Color]]
    stars: seq[tuple[rect: Rectangle, color: levels.Color]]
    triangles: seq[Point2D]

func initDrawOptions*(winSize: tuple[w, h: int], centerPoint = (winSize.w div 2, winSize.h div 2),
  borderColor = defaultBorderColor, bgColor = defaultBgColor): DrawOptions = 
  DrawOptions(
    winSize: winSize,
    shorterWinDimension: min(winSize.w, winSize.h),
    centerPoint: centerPoint,
    borderColor: borderColor,
    bgColor: bgColor
  )

func getDrawCoordSpace*(l: Level): DrawCoordSpace =
  let 
    totalMargin = insidePanelMargin + borderWidth + outsidePanelMargin
    totalMarginVec = (totalMargin, totalMargin)
  result.topLeft = (l.topLeftCorner - totalMarginVec)
  result.botRight = (l.botRightCorner + totalMarginVec)
  result.w = result.botRight.x - result.topLeft.x
  result.h = result.botRight.y - result.topLeft.y

func mazeDistToScreenDist(dist: float, s: DrawCoordSpace, o: DrawOptions): int =
  #TODO: Don't assume that height is the shorter window dimension
  result = (o.shorterWinDimension * (dist / s.h)).round.int

func relativeMazePos(l: Level, s: DrawCoordSpace, dist: Point2D): Point2D = 
  # Returns where a position is relative to the top left corner of the maze
  let panelCoordSpaceSize = s.botRight - s.topLeft
  result = dist / panelCoordSpaceSize

proc mazePosToScreenPos(l: Level, s: DrawCoordSpace, p: Point2D, o: DrawOptions): Point2DInt =
  # Transforms maze coordinates to screen pixel coordinates. This should 
  # be simplified quite a bit. Maybe get rid of the "coord space with margins"
  # mentioned in getPanelCoordSpace.
  result = o.centerPoint
  let panelCenter = midpoint(s.topLeft, s.botRight)
  let deltaFromCenter = l.relativeMazePos(s, (p.x - panelCenter.x, p.y - panelCenter.y))
  result = (
    o.centerPoint.x + (o.shorterWinDimension * deltaFromCenter.x).round.int,
    o.centerPoint.y + (o.shorterWinDimension * deltaFromCenter.y).round.int
  )

proc calcGfxData*(l: Level, s: DrawCoordSpace, o: DrawOptions): LevelGfxData =
  # Returns an object that contains screen positions for everything 
  # that needs to be drawn.
  for edge in l.pointGraph.getEdges():
    result.lineSegments.add (l.mazePosToScreenPos(s, edge.node1, o),
                             l.mazePosToScreenPos(s, edge.node2, o))
  let bgRectTopLeft = l.topLeftCorner - (insidePanelMargin, insidePanelMargin)
  let bgRectBotRight = l.botRightCorner + (insidePanelMargin, insidePanelMargin)
  result.bgRect = (
    l.mazePosToScreenPos(s, bgRectTopLeft, o),
    l.mazePosToScreenPos(s, bgRectBotRight, o) -
    l.mazePosToScreenPos(s, bgRectTopLeft, o)
  )
  result.lineWidth = mazeDistToScreenDist(lineWidth, s, o).float 
  result.startRadius = mazeDistToScreenDist(startRadius, s, o).float
  result.hexRadius = mazeDistToScreenDist(hexRadius, s, o).float
  for point, symbol in l.pointData.pairs:
    case symbol
    of Start:
      result.startingPoints.add l.mazePosToScreenPos(s, point, o) 
    of Hex:
      let screenPoint = l.mazePosToScreenPos(s, point, o) 
      result.hexes.add (screenPoint.x.float, screenPoint.y.float)
    else:
      discard
  for cell, symbol in l.cellData.pairs:
    let centerPoint = midpoint(cell)
    case symbol.kind
    of Square:
      let topLeft = centerPoint - (squareWidth / 2, squareWidth / 2)
      let length = mazeDistToScreenDist(squareWidth, s, o)
      let rectPos = l.mazePosToScreenPos(s, topLeft, o)
      let rect = Rectangle(
        x: rectPos.x.float, y: rectPos.y.float, 
        width: length.float, height: length.float
      )
      result.squares.add (rect, symbol.color)
    of Star:
      let length = mazeDistToScreenDist(squareWidth, s, o)
      let rectPos = l.mazePosToScreenPos(s, centerPoint, o)
      let rect = Rectangle(
        x: rectPos.x.float, y: rectPos.y.float, 
        width: length.float, height: length.float
      )
      result.stars.add (rect, symbol.color)
    of Triangles:
      result.triangleRadius = mazeDistToScreenDist(triangleRadius, s, o).float
      let screenCenter = l.mazePosToScreenPos(s, centerPoint, o)
      if symbol.count in {1, 3}:
        result.triangles.add (screenCenter.x.float, screenCenter.y.float)
      if symbol.count == 3:
        result.triangles.add (screenCenter.x.float - 2 * result.triangleRadius, screenCenter.y.float)
        result.triangles.add (screenCenter.x.float + 2 * result.triangleRadius, screenCenter.y.float)
      if symbol.count == 2:
        result.triangles.add (screenCenter.x.float - result.triangleRadius, screenCenter.y.float)
        result.triangles.add (screenCenter.x.float + result.triangleRadius, screenCenter.y.float)
    else:
      discard
  #TODO: Add blocks (tetris pieces)

proc draw*(l: Level, v: LevelGfxData) = 
  drawRectangleV(v.bgRect[0], v.bgRect[1], l.bgColor)
  for line in v.lineSegments:
    drawLineEx(line.p1, line.p2, v.lineWidth, l.fgColor)
  for point in v.startingPoints:
    drawCircle(point.x, point.y, v.startRadius, l.fgColor)
  for square in v.squares:
    drawRectangleRounded(square.rect, 0.5, 10, square.color)
  for star in v.stars:
    drawRectanglePro(star.rect, (star.rect.width, star.rect.height) / 2, 0.0, star.color)
    drawRectanglePro(star.rect, (star.rect.width, star.rect.height) / 2, 45.0, star.color)
  for hex in v.hexes:
    drawPoly(hex, 6, v.hexRadius, 0.0, (0, 0, 0))
  for triangle in v.triangles:
    drawPoly(triangle, 3, v.triangleRadius, 180.0, (255, 120, 0))
  #TODO: Add cell symbol drawing, maze borders, player line and rounded lines
