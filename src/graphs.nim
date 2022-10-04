import tables, sets, strformat

type
  Graph*[T] = object 
    ## An undirected graph with a generic node type. Adjacency lists are stored as a hash table of
    ## hash sets, that way checking if a node is in a graph is fast. Neighbor nodes' order doesn't 
    ## matter and removing/adding edges should be fast so neigbors are stored as a hash set.
    adjList*: Table[T, HashSet[T]]
  Edge*[T] = tuple[node1, node2: T] ## An edge of a graph in the form (node1, node2)
  Vec2*[T] = tuple[x, y: T]
  Point2D* = Vec2[float]
  Point2DInt* = Vec2[int]
  PointGraph* = Graph[Vec2[float]]

#TODO: Maybe switch to a vector library? Or at the very least move this into its own module.
proc `+`*[T](p1, p2: Vec2[T]): Vec2[T] = (p1.x + p2.x, p1.y + p2.y)
proc `-`*[T](p1, p2: Vec2[T]): Vec2[T] = (p1.x - p2.x, p1.y - p2.y)
proc `*`*[T](p1, p2: Vec2[T]): Vec2[T] = (p1.x * p2.x, p1.y * p2.y)
proc `*`*[T](p: Vec2[T], n: T): Vec2[T] = (p.x * n, p.y * n)
proc `/`*[T](p1, p2: Vec2[T]): Vec2[T] = (p1.x / p2.x, p1.y / p2.y)
proc `/`*[T](p: Vec2[T], n: T): Vec2[T] = (p.x / n, p.y / n)
proc `$`*[T](p: Vec2[T]): string = fmt"({p.x}, {p.y})"
proc `$`*(e: Edge): string = fmt"({e.node1} <-> {e.node2})"
proc midpoint*[T](p1, p2: Vec2[T]): Vec2[T] = (p1 + p2) / 2

proc addEdge*[T](g: var Graph, node1: T, node2: T) =
  g.adjList[node1].incl node2
  g.adjList[node2].incl node1
proc removeEdge*[T](g: var Graph, node1: T, node2: T) =
  g.adjList[node1].excl node2
  g.adjList[node2].excl node1

proc addNode*[T](g: var Graph, node: T) = g.adjList[node] = initHashSet[T]()
proc removeNode*[T](g: var Graph, node: T) = g.adjList.del node

iterator nodes*[T](g: Graph[T]): T =
  for node in g.adjList.keys:
    yield node

# For some reason I had to specify Graph[T] in the proc signature below or else,
# this function would have to be called by specyfing the node type e.g. getEdges[Vec2[float]](graph).
proc getEdges*[T](g: Graph[T]): HashSet[Edge[T]] =
  for node1 in g.adjList.keys:
    for node2 in g.adjList[node1]:
      if (node2, node1) notin result:
        result.incl (node1, node2)

iterator gridPoints*(p1, p2: Vec2[float]): Vec2[float] =
  ## Iterates over a rectangular region of coordinates
  for x in p1.x.int .. p2.x.int:
    for y in p1.y.int .. p2.y.int:
      yield (x.float, y.float)

iterator adjacentGridPoints*(p: Vec2[float]): Vec2[float] =
  const adjacents: array[4, Vec2[float]] = [(1.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (0.0, -1.0)]
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

func findReachableNodes*[T](g: Graph, node: T): HashSet[T] =
  var visited = initHashSet[T]()
  # Inner function used so that the visited set can be initialized outside the dfs function
  proc findReachableNodesInner[T](g: Graph, node: T) =
    visited.incl node
    for neighbor in g.adjList[node]:
      if neighbor notin visited:
        g.findReachableNodesInner(neighbor)
  findReachableNodesInner(g, node)
  return visited

func hasRoute*[T](g: Graph, currNode, goalNode: T): bool =
  var visited = initHashSet[T]()
  proc hasRouteInner[T](g: Graph, currNode, goalNode: T): bool =
    if currNode == goalNode:
      return true
    visited.incl currNode
    for neighbor in g.adjList[currNode]:
      if neighbor notin visited:
        return g.hasRouteInner(neighbor, goalNode)
  return hasRouteInner[T](g, currNode, goalNode)
