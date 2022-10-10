# The Witness puzzle maker
Algorithms and data structures student project

# Images from the original game
![Mazes with squares](https://oyster.ignimgs.com/mediawiki/apis.ign.com/the-witness/c/cb/Bwunsolved2.jpg)
![Maze with tetris pieces](https://oyster.ignimgs.com/mediawiki/apis.ign.com/the-witness/0/02/Blueblocksunsolved.jpg)

# Documentation
- [Project specification](docs/project_definition.md)
- [User guide](docs/user_guide.md)
- [Testing document](docs/testing.md)
- [Implementation document](docs/implementation.md)
- [First week report](docs/week1_report.md)
- [Second week report](docs/week2_report.md)
- [Third week report](docs/week3_report.md)
- [Fourth week report](docs/week4_report.md)
- [Fifth week report](docs/week5_report.md)

# Notes for code reviewers
Nim is quite similar to Python in many ways, but some parts are very different. For example Nim functions can use generic types, function calls can use weird syntax sometimes and everything is statically typed. If you don't
know Nim you should start by looking at the graph library src/graphs.nim. There I have lots of comments to help you understand the Nim code in this project. These comments start with NIMNOTE. Feel free to skip them if you
understand my code (very likely if you know both Python and a language with generics and static typing). Another quite important module is src/levels.nim that defines the level format used by the game.
