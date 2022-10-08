# Installing dependencies (Linux only)
This project uses a C game development library and unfortunately that means u need quite a bit of other libraries if u are running Linux. 

# Installing Nim and its package manager (Linux)
Run the following command in a terminal. It will download Nim to ~/.nimble/ and export the path where Nim binaries are. (Edit the command if u want to add Nim to the PATH variable yourself.)
```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh; echo 'export PATH=~/.nimble/bin:$PATH' > .profile 
```

# Installing Nim and its package manager (Windows)
Download choosenim executable from [here](https://github.com/dom96/choosenim/releases) and run it to install Nim.

# Installing the project from source (Linux)
In the future I will have binaries in github realeases, but right now the project can be installed using Nim's package manager by running the following command:
```
choosenim devel; nimble refresh; nimble install https://github.com/Cloudperry/the-witness-puzzle-maker
```
If you have added Nim to your path the editor and the game can be opened by running witness-clone-editor or witness-clone in a terminal. I will change the binary names later, because they are way too generic.

# Installing the project from source (Windows)
```
choosenim devel && nimble refresh && nimble install https://github.com/Cloudperry/the-witness-puzzle-maker
```
