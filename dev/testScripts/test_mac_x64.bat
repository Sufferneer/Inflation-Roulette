@echo off
cd ../..
echo BUILDING GAME...
haxelib run lime test mac -D_OFFICIAL_BUILD
echo.
echo Compress the contents into a zip file named Inflation-Roulette_<VERSION_NAME>_Mac64
pause
pwd
explorer.exe export\release\mac\bin