from math import round
import lenientops, tables, sets
import nimraylib_now
import levels, graphs

const
  #TODO: Maybe change line thickness and start radius to use level space coordinates instead of raw pixels
  borderThickness = 0.25
  lineThickness = 10
  startRadius = 15
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
    centerPoint*: Point2DInt ## Point on the screen where the center of the maze should be
    borderColor*: levels.Color
    bgColor*: levels.Color
  LevelScreenVertices* = object 
    ## This object is used to store pixel coordinates for the level.
    ## It is used when drawing the level
    lineSegments: LineSeq
    startingPoints: seq[Point2DInt]
    bgRect: tuple[topLeftCorner, size: Point2DInt]

#TODO: Name the following initializer function properly
proc drawOptions*(winSize: tuple[w, h: int]): DrawOptions =
  result = DrawOptions(
    winSize: winSize,
    centerPoint: (winSize.w div 2, winSize.h div 2),
    borderColor: defaultBorderColor,
    bgColor: defaultBgColor
  )

func getPanelCoordSpace(l: Level): 
  # This function has a bad name. Actually it just adds margins to the level
  # coord space to get the coordinate space used to draw the panel and to make
  # sure it leaves big enough margins on screen edges.
  tuple[topLeft, botRight: Point2D] =
  let 
    totalMargin = insidePanelMargin + borderThickness + outsidePanelMargin
    totalMarginVec = (totalMargin, totalMargin)
  result.topLeft = (l.topLeftCorner - totalMarginVec)
  result.botRight = (l.botRightCorner + totalMarginVec)

func relativeMazeDist(l: Level, dist: Point2D): Point2D = 
  # Returns how a given distance is relative to the 
  # coord space given by the function above.
  let panelCoordSpace = l.getPanelCoordSpace()
  let panelCoordSpaceSize = panelCoordSpace.botRight - panelCoordSpace.topLeft
  result = dist / panelCoordSpaceSize

proc mazePosToScreenPos(l: Level, p: Point2D, o: DrawOptions): Point2DInt =
  # Transforms maze coordinates to screen pixel coordinates. This should 
  # be simplified quite a bit. Maybe get rid of the "coord space with margins"
  # mentioned in getPanelCoordSpace.
  result = o.centerPoint
  let panelCoordSpace = l.getPanelCoordSpace()
  let panelCenter = midpoint(panelCoordSpace.topLeft, panelCoordSpace.botRight)
  let shorterWinDimension = min(o.winSize.w, o.winSize.h)
  let deltaFromCenter = l.relativeMazeDist((p.x - panelCenter.x, p.y - panelCenter.y))
  result = (
    o.centerPoint.x + (shorterWinDimension * deltaFromCenter.x).round.int,
    o.centerPoint.y + (shorterWinDimension * deltaFromCenter.y).round.int
  )

proc getScreenVertices*(l: Level, o: DrawOptions): LevelScreenVertices =
  # Returns an object that contains screen positions for everything 
  # that needs to be drawn.
  for edge in l.pointGraph.getEdges():
    result.lineSegments.add (l.mazePosToScreenPos(edge.node1, o),
                             l.mazePosToScreenPos(edge.node2, o))
  for point in l.pointGraph.nodes:
    if l.pointData[point] == Start: 
      result.startingPoints.add l.mazePosToScreenPos(point, o) 
  let bgRectTopLeft = l.topLeftCorner - (insidePanelMargin, insidePanelMargin)
  let bgRectBotRight = l.botRightCorner + (insidePanelMargin, insidePanelMargin)
  result.bgRect = (
    l.mazePosToScreenPos(bgRectTopLeft, o),
    l.mazePosToScreenPos(bgRectBotRight, o) -
    l.mazePosToScreenPos(bgRectTopLeft, o)
  )
  #TODO: Add cell symbols placement logic

proc draw*(l: Level, v: LevelScreenVertices) = 
  drawRectangleV(v.bgRect[0], v.bgRect[1], l.bgColor)
  for line in v.lineSegments:
    drawLineEx(line.p1, line.p2, lineThickness, l.fgColor)
  for point in v.startingPoints:
    drawCircle(point.x, point.y, startRadius, l.fgColor)
  #TODO: Add cell symbol drawing, maze borders, player line and rounded lines
