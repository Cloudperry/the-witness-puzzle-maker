# Installing Nim and its package manager (Linux)
Run the following command in a terminal and follow the instructions from the installer to add Nim to your PATH:
```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

# Installing Nim and its package manager (Windows)
Download choosenim executable from [here](https://github.com/dom96/choosenim/releases) and run it to install Nim.

# Switching to Nim devel version
Right now this project uses the development version of Nim so you need to switch Nim versions by running this command:
```
choosenim devel
```
If the command fails make sure you have added Nim to your PATH and restarted your terminal.

# Installing the project from source
In the future I will have binaries in github realeases, but right now the project can be installed using Nim's package manager by running the following command:
```
nimble install https://github.com/Cloudperry/the-witness-puzzle-maker
```
If you have added Nim to your path the editor and the game can be opened by running witness-clone-editor or witness-clone in a terminal. I will change the binary names later, because they are way too generic.
