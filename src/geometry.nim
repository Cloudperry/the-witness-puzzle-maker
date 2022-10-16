import std/[math, lenientops, tables, strformat, options]
import graphs

type
  Vec2*[N: SomeNumber] = tuple[x, y: N]
    # NIMNOTE: Generics can be constrained to specific types. Here N is restricted
    # to be a number (float or int of any size).
  Point2D* = Vec2[float]
    # NIMNOTE: Symbols marked with asterisk are exported symbols. That means 
    # only symbols with asterisk can be used outside the module they are declared in.
  Point2DInt* = Vec2[int]
  PointGraph* = Graph[Vec2[float]]
  Line* = seq[Point2D]
  LineSegments* = seq[tuple[p1, p2: Point2D]]

proc `+`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x + p2.x, p1.y + p2.y) 
  # NIMNOTE: The first expression in a function that produces a value will be 
  # the return value. Operators can be overridden by having the operator in backticks.
proc `+`*[N: SomeNumber](p: Vec2, n: N): Vec2[N] = (p.x + n, p.y + n)
proc `-`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x - p2.x, p1.y - p2.y)
proc `-`*[N: SomeNumber](p: Vec2, n: N): Vec2[N] = (p.x - n, p.y - n)
proc `-`*[N: SomeNumber](p: Vec2[N]): Vec2[N] = (-p.x, -p.y)
proc `*`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x * p2.x, p1.y * p2.y)
proc `/`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x / p2.x, p1.y / p2.y)
proc `*`*[V: SomeNumber, S: SomeNumber](p: Vec2[V], n: S): Vec2[V] = 
  (p.x * n, p.y * n)
proc `/`*[V: SomeNumber, S: SomeNumber](p: Vec2[V], n: S): Vec2[V] =
  (p.x / n, p.y / n)
proc `$`*[N: SomeNumber](p: Vec2[N]): string = fmt"({p.x}, {p.y})"
proc midpoint*[N: SomeNumber](vectors: varargs[Vec2[N]]): Vec2[N] =
  ## Generalization of the normal 2 points midpoint formula "(A + B) / 2" to n points
  sum(vectors) / vectors.len
proc toInt*(p: Point2D): Point2DInt = (p.x.round.int, p.y.round.int)
proc toFloat*(p: Point2DInt): Point2D = (p.x.float, p.y.float)
proc len*[N: SomeNumber](p: Vec2[N]): float = 
  let squared = p * p
  sqrt(squared.x + squared.y)
proc toUnitVec*[N: SomeNumber](p: Vec2[N]): Vec2[N] = p / p.len
proc rotateAroundOrigin*[N: SomeNumber](p: Vec2[N], angle: float): Vec2[N] =
  (cos(angle), sin(angle)) * p.x + (-sin(angle), cos(angle)) * p.y

iterator gridPoints*(p1, p2: Vec2[float]): Vec2[float] =
  ## Iterates over a rectangular region of coordinates
  for x in p1.x.int .. p2.x.int:
    for y in p1.y.int .. p2.y.int:
      yield (x.float, y.float)

iterator adjacentGridPoints*(p: Vec2[float]): Vec2[float] =
  const adjacents: array[4, Vec2[float]] = [
    (1.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (0.0, -1.0)
  ]
  for delta in adjacents:
    yield (p.x + delta.x, p.y + delta.y)

proc addGridPoints*(g: var PointGraph, p1, p2: Vec2[float]) =
  ## Adds nodes in a rectangular region of coordinates to the graph
  for point in gridPoints(p1, p2):
    g.addNode point

proc connectGridPoints*(g: var PointGraph, p1, p2: Vec2[float]) =
  ## Connects all nodes in a rectangular region of coordinates
  for currPoint in gridPoints(p1, p2):
    for adjPoint in adjacentGridPoints(currPoint):
      if adjPoint in g.adjList:
        g.addEdge(currPoint, adjPoint)

# Convenience operators for building a line from points
proc `->`*(a, b: Point2D): seq[Point2D] = @[a, b]
proc `->`*(a: Line, b: Point2D): seq[Point2D] = a & b

proc lineToSegments*(line: seq[Point2D]): seq[tuple[p1, p2: Point2D]] =
  var prevPoint: Option[Point2D]
  for point in line:
    if prevPoint.isSome:
      result.add (prevPoint.get, point)
    prevPoint = some(point)
