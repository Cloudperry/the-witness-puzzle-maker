import std/[strformat, tables, sets]

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

proc `<->`*[N](node1, node2: N): Edge[N] = (node1, node2)

proc addEdge*[T](g: var Graph; node1, node2: T) =
  g.adjList[node1].incl node2
  g.adjList[node2].incl node1
  # NIMNOTE: Here .incl uses a function call syntax that actually means 
  # incl(g.adjList[node1], node2). Also parentheses can be replaced with
  # a space and an argument (mostly done when only 1 argument comes after the space).
proc addEdgeAndMissingNodes*[T](g: var Graph, node1, node2: T) =
  if node1 notin g.adjList:
    g.addNode(node1)
  if node2 notin g.adjList:
    g.addNode(node2)
  g.addEdge(node1, node2)
proc removeEdge*[T](g: var Graph; node1, node2: T) =
  g.adjList[node1].excl node2
  g.adjList[node2].excl node1
proc `$`*(e: Edge): string = fmt"({e.node1} <-> {e.node2})"

proc addNode*[T](g: var Graph, node: T) = g.adjList[node] = initHashSet[T](4)
proc removeNode*[T](g: var Graph, node: T) =
  var removedNodeNeighbors: HashSet[T]
  if g.adjList.pop(node, removedNodeNeighbors):
    for neighbor in removedNodeNeighbors: 
      g.adjList[neighbor].excl node
proc contains*[T](g: Graph, node: T): bool = node in g.adjList

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

func dfs*[T](g: Graph, node: T, stopAt: HashSet[T]): HashSet[T] =
  # NIMNOTE: "Normal" functions in Nim are declared with proc and functions 
  # that don't have any side-effects are declared with func. These functions
  # can't modify any variables outside their scope and can't print for example.
  var visited: HashSet[T]
  # Line below is a workaround for a Nim bug. dfsInner should get all variables that are from dfs'
  # scope. Using generics somehow confuses the compiler and stopAt doesn't get passed through 
  # without declaring it again in the body.
  let stopAt = stopAt 
  proc dfsInner[T](g: Graph, node: T) =
    visited.incl node
    if node in stopAt: return
    for neighbor in g.adjList[node]:
      if neighbor notin visited:
        g.dfsInner(neighbor)
  dfsInner(g, node)
  return visited

func findReachableNodes*[T](g: Graph, node: T): HashSet[T] = 
  g.dfs(node, stopAt = initHashSet[T]())

func hasRoute*[T](g: Graph, startNode, goalNode: T): bool =
  return goalNode in g.dfs(startNode, stopAt = [goalNode].toHashSet)
