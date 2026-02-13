@echo off
cd ../..
echo BUILDING GAME...
haxelib run lime test linux -D_OFFICIAL_BUILD
echo.
echo Compress the contents into a zip file named Inflation-Roulette_<VERSION_NAME>_Linux64
pause
pwd
explorer.exe export\release\linux\bin