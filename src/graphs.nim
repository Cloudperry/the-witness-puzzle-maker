import tables, sets, strformat

type
  Point2D* = tuple[x, y: int]
  Graph*[T] = object # An undirected graph with a generic node type
    ##Store adjacency list as a hash table of hash sets, that way checking if a node is in a graph is fast
    ##Neighbor nodes' order doesn't matter and removing/adding edges should be fast so neigbors are stored as a hash set
    adjList*: Table[T, HashSet[T]]
  PointGraph* = Graph[Point2D]

proc `$`*(p: Point2D): string = fmt"({p.x}, {p.y})"

proc addEdge*[T](g: var Graph, node1: T, node2: T) =
  g.adjList[node1].incl node2
  g.adjList[node2].incl node1
proc removeEdge*[T](g: var Graph, node1: T, node2: T) =
  g.adjList[node1].excl node2
  g.adjList[node2].excl node1

proc addNode*[T](g: var Graph, node: T) = g.adjList[node] = initHashSet[T]()
proc removeNode*[T](g: var Graph, node: T) = g.adjList.del node

iterator gridPoints*(p1, p2: Point2D): Point2D =
  ##Iterates over a rectangular region of coordinates
  for x in p1.x .. p2.x:
    for y in p1.y .. p2.y:
      yield (x, y)

iterator adjacentPoints*(p: Point2D): Point2D =
  const adjacents: array[4, Point2D] = [(1, 0), (0, 1), (-1, 0), (0, -1)]
  for delta in adjacents:
    yield (p.x + delta.x, p.y + delta.y)

proc addGridNodes*(g: var PointGraph, p1, p2: Point2D) =
  ##Adds nodes in a rectangular region of coordinates to the graph
  for point in gridPoints(p1, p2):
    g.addNode point

proc connectGridNodes*(g: var PointGraph, p1, p2: Point2D) =
  ##Connects all nodes in a rectangular region of coordinates
  for currPoint in gridPoints(p1, p2):
    for adjPoint in adjacentPoints(currPoint):
      if adjPoint in g.adjList:
        g.addEdge(currPoint, adjPoint)

func findReachableNodes*[T](g: Graph, node: T): HashSet[T] =
  var visited = initHashSet[T]()
  #Inner function used so that the visited set can be initialized outside the dfs function
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
