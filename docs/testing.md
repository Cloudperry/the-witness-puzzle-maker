# Unit test coverage
I have only one core functionality implemented (a graph library) that is tested with almost 100% coverage. For now the rest of the project is just UI code. The graph library was tested by making a graph of a 5x5 grid with
the nodes not connected to anything at first. Then I connected all the nodes and separated 3 nodes completely from the rest of the graph. The graph was checked after almost every change. At the end of the test I check that
route existence checking and finding connected nodes works. The test coverage report can be found on [Github pages](https://cloudperry.github.io/the-witness-puzzle-maker/coverage/index.html).

# Running the tests
First follow the steps in [User guide](docs/user_guide.md) to install Nim and to switch to devel version of Nim. Then the tests can be run by cloning this repository, opening it in a terminal and running "nimble test".
