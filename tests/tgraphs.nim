import tables, sets
import ../src/graphs

var testGraph: PointGraph

testGraph.addGridNodes((0, 0), (4, 4)) #Create a 5x5 grid of nodes from (0, 0) to (4, 4)
for x, y in gridPoints((0, 0), (4, 4)):
  assert (x, y) in testGraph.adjList #Check that each coordinate has the node
for point in gridPoints((0, 0), (4, 4)):
  for adjacentPoint in adjacentPoints(point):
    if adjacentPoint in testGraph.adjList:
      #Check that there are no connections in the graph
      assert testGraph.hasRoute(point, adjacentPoint) == false

testGraph.connectGridNodes((0, 0), (4, 4))
#Remove all connections to points (2, 2), (3, 2) and (2, 3)
testGraph.removeEdge((2, 1), (2, 2))
testGraph.removeEdge((1, 2), (2, 2))
testGraph.removeEdge((3, 1), (3, 2))
testGraph.removeEdge((4, 2), (3, 2))
testGraph.removeEdge((3, 3), (3, 2))
testGraph.removeEdge((1, 3), (2, 3))
testGraph.removeEdge((2, 4), (2, 3))
testGraph.removeEdge((3, 3), (2, 3))
#Check that the points mentioned above are really detached from the rest of the Graph
assert testGraph.findReachableNodes((2, 2)) == [(2, 2), (3, 2), (2, 3)].toHashSet
assert testGraph.hasRoute((2, 2), (3, 2)) == true
assert testGraph.hasRoute((2, 2), (0, 0)) == false

echo "Graph library (graphs.nim) tests ran successfully."
