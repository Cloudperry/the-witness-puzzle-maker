import tables, sets
import ../src/graphs

var testGraph: PointGraph

testGraph.addGridPoints((0.0, 0.0), (4.0, 4.0)) #Create a 5x5 grid of nodes from (0, 0) to (4, 4)
for x, y in gridPoints((0.0, 0.0), (4.0, 4.0)):
  assert (x, y) in testGraph.adjList #Check that each coordinate has the node
for point in gridPoints((0.0, 0.0), (4.0, 4.0)):
  for adjacentPoint in adjacentGridPoints(point):
    if adjacentPoint in testGraph.adjList:
      #Check that there are no connections in the graph
      assert testGraph.hasRoute(point, adjacentPoint) == false

testGraph.connectGridPoints((0.0, 0.0), (4.0, 4.0))
#Remove all connections to points (2, 2), (3, 2) and (2, 3)
testGraph.removeEdge((2.0, 1.0), (2.0, 2.0))
testGraph.removeEdge((1.0, 2.0), (2.0, 2.0))
testGraph.removeEdge((3.0, 1.0), (3.0, 2.0))
testGraph.removeEdge((4.0, 2.0), (3.0, 2.0))
testGraph.removeEdge((3.0, 3.0), (3.0, 2.0))
testGraph.removeEdge((1.0, 3.0), (2.0, 3.0))
testGraph.removeEdge((2.0, 4.0), (2.0, 3.0))
testGraph.removeEdge((3.0, 3.0), (2.0, 3.0))
#Check that the points mentioned above are really detached from the rest of the Graph
assert testGraph.findReachableNodes((2.0, 2.0)) == [(2.0, 2.0), (3.0, 2.0), (2.0, 3.0)].toHashSet
assert testGraph.hasRoute((2.0, 2.0), (3.0, 2.0)) == true
assert testGraph.hasRoute((2.0, 2.0), (0.0, 0.0)) == false

echo "Graph library (graphs.nim) tests ran successfully."
