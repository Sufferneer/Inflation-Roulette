# Compilation Guide
Here is a comprehensive guide on how to compile the game from source.
## Basic Setup
### 0 - Setup
1. Download [Haxe](https://haxe.org).
2. Download [Git](https://git-scm.com). (not required for the safer option)
### I - Downloading The Source Code
Although you can download the source code straight from the GitHub repository, it is *safer* to use Git to clone the repository instead to minimize the chance of running into errors.
#### Git Clone Option (safer):
1. Open a command prompt.
2. Run `cd the\directory\of\the\source\code` to specify where should the command prompt work on.
3. Run `git clone https://github.com/Sufferneer/Inflation-Roulette.git` to clone the base repository.

#### Direct Download Option (easier):
1. Download the source code from the lastest branch.
2. Extract the zip file's contents to your desired directory.

### II - Installing Dependancies
1. Open the project folder, and open a command prompt inside that directory.
2. Run `haxelib --global install hmm`, then run `haxelib --global run hmm setup` to install hmm.
3. Run `hmm install` to install all dependent haxelibs.

## Platform-Dependent Setup
The game only supports Windows and HTML as of now. For the game to build on your desired platform, follow these instructions:
### Windows
1. Download [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe)
2. When prompted, select "Individual Components" and download the following:
	- MSVC v143 VS 2022 C++ x64/x86 build tools
	- Windows 10/11 SDK
### HTML
The game compiles without additional setup.

## Building
Run `lime test <PLATFORM>` to build and launch the game for your platform. (for example, `lime test windows`)

# [Back To Main Page](MAIN_PAGE.md)