<details>
  <summary>Linux install instructions (click to expand)</summary>

  # Installing dependencies
  This project uses a C game development library and that means quite a bit of libraries are needed on Linux. Below I have the commands to install dependencies for a few common Linux
  distributions.

  Ubuntu:
  ```
  sudo apt install libasound2-dev mesa-common-dev libx11-dev libxrandr-dev libxi-dev xorg-dev libgl1-mesa-dev libglu1-mesa-dev
  ```
  Fedora:
  ```
  sudo dnf install alsa-lib-devel mesa-libGL-devel libX11-devel libXrandr-devel libXi-devel libXcursor-devel libXinerama-devel libatomic
  ```
  Arch Linux:
  ```
  sudo pacman -S alsa-lib mesa libx11 libxrandr libxi libxcursor libxinerama
  ```

  # Installing Nim compiler and its package manager
  Run the following command in a terminal. It will download Nim to ~/.nimble/ and export the path where Nim binaries are. (Edit the command if you want to add Nim to the PATH variable yourself.)
  ```
  curl https://nim-lang.org/choosenim/init.sh -sSf | sh; echo 'export PATH=~/.nimble/bin:$PATH' > .profile 
  ```

  # Downloading the project
  Restart the terminal to make sure PATH has been updated. Then run this command to prepare the Nim environment and download the project:
  ```
  choosenim devel; nimble refresh; git clone https://github.com/Cloudperry/the-witness-puzzle-maker; cd the-witness-puzzle-maker
  ```
</details>

<details>
  <summary>Mac OS install instructions (click to expand)</summary>

  # Installing dependencies (Mac OS)
  Nim uses a C compiler. If you don't have one installed run the following command in a terminal to install Clang on Mac OS.
  ```
  xcode-select --install
  ```

  # Installing Nim compiler and its package manager
  Run the following command in a terminal. It will download Nim to ~/.nimble/ and export the path where Nim binaries are. (Edit the command if you want to add Nim to the PATH variable yourself.)
  ```
  curl https://nim-lang.org/choosenim/init.sh -sSf | sh; echo 'export PATH=~/.nimble/bin:$PATH' > .profile 
  ```

  # Downloading the project
  Restart the terminal to make sure PATH has been updated. Then run this command to prepare the Nim environment and download the project:
  ```
  choosenim devel; nimble refresh; git clone https://github.com/Cloudperry/the-witness-puzzle-maker; cd the-witness-puzzle-maker
  ```

  Run this command to compile the project. It will take about 5 min, because it has to download some libraries and generate bindings for one of the libraries.
  ```
  nimble build
  ```
</details>

<details>
  <summary>Windows install instructions (click to expand)</summary>
  # Installing Nim and its package manager (Windows)
  Download choosenim zip file [here](https://github.com/dom96/choosenim/releases), extract it and open runme.bat to install Nim.

  # Installing Git for Windows
  If you don't have a git environment installed, download and install [Git for Windows](https://gitforwindows.org/).

  # Downloading the project
  Run this command to prepare the Nim environment and download the project:
  ```
  choosenim devel && nimble refresh && git clone https://github.com/Cloudperry/the-witness-puzzle-maker && cd /d the-witness-puzzle-maker
  ```
  If you executed runme.bat in a terminal, you might need to restart the terminal for the command above to work.
</details>

# Compiling the project (do this after installing the project and dependencies)
Run this command in the project directory to compile the project. It might take about 5 min, because it has to download some libraries and generate bindings for one of the libraries.
```
nimble build
```

# Running the program
The game executable is witness-clone and the editor is witness-clone-editor. You can pass the level file as the first argument to open a level. Sample levels can be found in the levels directory.

# Generating test coverage and other project actions (defined in theWitnessPuzzles.nimble)
Run tests:
```
nimble test
```

Generate test coverage:
```
nimble gencoverage
```

Generate source code documentation:
```
nimble gendocs
```
