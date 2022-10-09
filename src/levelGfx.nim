from std/math import round
import std/[lenientops, tables, sets]
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
  startRadius = 0.2
  squareWidth = 0.3
  insidePanelMargin = 0.5
  outsidePanelMargin = 1.0
  defaultBorderColor = (140, 140, 155) # Maybe border color should be themeable by the level
  defaultBgColor = (80, 80, 80)

converter point2DToVec2(p: Point2DInt): Vector2 = Vector2(x: p.x.cfloat, y: p.y.cfloat)

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
    startRadius, lineWidth: float
    squares: seq[tuple[rect: Rectangle, color: levels.Color]]

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

func relativeMazeDist(l: Level, s: DrawCoordSpace, dist: Point2D): Point2D = 
  # Returns how a given distance is relative to the 
  # coord space given by the function above.
  let panelCoordSpaceSize = s.botRight - s.topLeft
  result = dist / panelCoordSpaceSize

proc mazePosToScreenPos(l: Level, s: DrawCoordSpace, p: Point2D, o: DrawOptions): Point2DInt =
  # Transforms maze coordinates to screen pixel coordinates. This should 
  # be simplified quite a bit. Maybe get rid of the "coord space with margins"
  # mentioned in getPanelCoordSpace.
  result = o.centerPoint
  let panelCenter = midpoint(s.topLeft, s.botRight)
  let deltaFromCenter = l.relativeMazeDist(s, (p.x - panelCenter.x, p.y - panelCenter.y))
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
  for point in l.pointGraph.nodes:
    if l.pointData[point] == Start: 
      result.startingPoints.add l.mazePosToScreenPos(s, point, o) 
  let bgRectTopLeft = l.topLeftCorner - (insidePanelMargin, insidePanelMargin)
  let bgRectBotRight = l.botRightCorner + (insidePanelMargin, insidePanelMargin)
  result.bgRect = (
    l.mazePosToScreenPos(s, bgRectTopLeft, o),
    l.mazePosToScreenPos(s, bgRectBotRight, o) -
    l.mazePosToScreenPos(s, bgRectTopLeft, o)
  )
  result.lineWidth = mazeDistToScreenDist(lineWidth, s, o).float 
  result.startRadius = mazeDistToScreenDist(startRadius, s, o).float
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
    else:
      discard
  #TODO: Add cell symbols placement logic

proc draw*(l: Level, v: LevelGfxData) = 
  drawRectangleV(v.bgRect[0], v.bgRect[1], l.bgColor)
  for line in v.lineSegments:
    drawLineEx(line.p1, line.p2, v.lineWidth, l.fgColor)
  for point in v.startingPoints:
    drawCircle(point.x, point.y, v.startRadius, l.fgColor)
  for square in v.squares:
    drawRectangleRounded(square.rect, 0.5, 10, square.color)
  #TODO: Add cell symbol drawing, maze borders, player line and rounded lines
