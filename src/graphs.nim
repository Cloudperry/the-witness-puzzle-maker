import std/[math, lenientops, strformat, tables, sets]

type
  Graph*[N] = object 
    # NIMNOTE: Nim objects are like structs in C. Nim has generics like 
    # C++, Rust or Go. Here N is the type of the graph nodes. 
    # Comments starting with double hash are documentation comments that 
    # will show up in the generated source code documentation.
    ## An undirected graph with a generic node type. Adjacency lists are stored as a hash table of
    ## hash sets, that way checking if a node is in a graph is fast. Neighbor nodes' order doesn't 
    ## matter and removing/adding edges should be fast so neigbors are stored as a hash set.
    adjList*: Table[N, HashSet[N]]
  Edge*[N] = tuple[node1, node2: N] ## An edge of a graph in the form (node1, node2)
  Vec2*[N: SomeNumber] = tuple[x, y: N]
    # NIMNOTE: Generics can be constrained to specific types. Here N is restricted
    # to be a number (float or int of any size).
  Point2D* = Vec2[float]
    # NIMNOTE: Symbols marked with asterisk are exported symbols. That means 
    # only symbols with asterisk can be used outside the module they are declared in.
  Point2DInt* = Vec2[int]
  PointGraph* = Graph[Vec2[float]]

#TODO: Maybe switch to a vector library? Or at the very least move this into its own module.
proc `+`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x + p2.x, p1.y + p2.y) 
  # NIMNOTE: The first expression in a function that produces a value will be 
  # the return value. Operators can be overridden by having the operator in backticks.
proc `-`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x - p2.x, p1.y - p2.y)
proc `*`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x * p2.x, p1.y * p2.y)
proc `/`*[N: SomeNumber](p1, p2: Vec2[N]): Vec2[N] = (p1.x / p2.x, p1.y / p2.y)
proc `*`*[V: SomeNumber, S: SomeNumber](p: Vec2[V], n: S): Vec2[V] = 
  (p.x * n, p.y * n)
proc `/`*[V: SomeNumber, S: SomeNumber](p: Vec2[V], n: S): Vec2[V] =
  (p.x / n, p.y / n)
proc `$`*[N: SomeNumber](p: Vec2[N]): string = fmt"({p.x}, {p.y})"
proc midpoint*[N: SomeNumber](vectors: varargs[Vec2[N]]): Vec2[N] =
  ## Generalization of the normal (A + B) / 2 midpoint formula for 2 points to n points
  sum(vectors) / vectors.len

proc addEdge*[T](g: var Graph, node1: T, node2: T) =
  g.adjList[node1].incl node2
  g.adjList[node2].incl node1
  # NIMNOTE: Here .incl uses a function call syntax that actually means 
  # incl(g.adjList[node1], node2). Also parentheses can be replaced with
  # a space and an argument (mostly done when only 1 argument comes after the space).
proc removeEdge*[T](g: var Graph, node1: T, node2: T) =
  g.adjList[node1].excl node2
  g.adjList[node2].excl node1
proc `$`*(e: Edge): string = fmt"({e.node1} <-> {e.node2})"

proc addNode*[T](g: var Graph, node: T) = g.adjList[node] = initHashSet[T](4)
proc removeNode*[T](g: var Graph, node: T) = g.adjList.del node

iterator nodes*[T](g: Graph[T]): T = # NIMNOTE: Iterators work just like python generator functions
  for node in g.adjList.keys:
    yield node

proc getEdges*[T](g: Graph[T]): HashSet[Edge[T]] =
  # NIMNOTE: Any function with a declared return type will have the implicitly
  # defined result variable that is initialized to default value of the return type
  # (in this case empty set). After the function is done executing this variable will
  # be returned automatically.
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

func findReachableNodes*[T](g: Graph, node: T): HashSet[T] =
  # NIMNOTE: "Normal" functions in Nim are declared with proc and functions 
  # that don't have any side-effects are declared with func. These functions
  # can't modify any variables outside their scope and can't print for example.
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
  # Same as the previous function, but the dfs terminates when goal node is found
  proc hasRouteInner[T](g: Graph, currNode, goalNode: T) =
    visited.incl currNode
    if currNode == goalNode: return
    for neighbor in g.adjList[currNode]:
      if neighbor notin visited:
        g.hasRouteInner(neighbor, goalNode)
  hasRouteInner(g, currNode, goalNode)
  return goalNode in visited
