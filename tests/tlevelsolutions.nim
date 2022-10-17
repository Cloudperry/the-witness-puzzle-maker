import std/[tables, sets, lenientops, os]
import ../src/levels, ../src/graphs, ../src/geometry

let 
  hexTutorial1 = loadLevelFromFile("levels/hexTutorial1.bin")
  hexTutorial2 = loadLevelFromFile("levels/hexTutorial2.bin") #TODO: Add a few tests for this level (its a bit more complex)

const wrongSolutionsTut1 = [ 
  # This line is wrong because it doesn't start from a start point
  (0.0, 0.0) -> (1.0, 0.0) -> (1.0, 1.0) -> (1.0, 2.0) -> (2.0, 2.0) -> 
  (2.0, 1.0) -> (2.0, 0.0) -> (2.0, -0.25),
  # This line is wrong because it doesn't go through any of the hexes
  (0.0, 2.0) -> (1.0, 2.0) -> (1.0, 1.0) -> (2.0, 1.0) -> (2.0, 0.0) ->
  (2.0, -0.25)
]
const correctSolutionsTut1 = [
  (0.0, 2.0) -> (0.0, 1.0) -> (0.0, 0.0) -> (1.0, 0.0) -> (1.0, 1.0) -> 
  (1.0, 2.0) -> (2.0, 2.0) -> (2.0, 1.0) -> (2.0, 0.0) -> (2.0, -0.25)
]

for line in wrongSolutionsTut1: 
  # Check that the solution checker denies all the wrong solutions
  assert not hexTutorial1.checkSolution(line)

for line in correctSolutionsTut1:
  # Check that the solution checker accepts all the correct solutions
  assert hexTutorial1.checkSolution(line)

echo "level solution algorithm (levels.nim) tests ran successfully."
