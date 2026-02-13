@echo off
cd ../..
echo BUILDING GAME...
haxelib run lime test mac -32 -D_OFFICIAL_BUILD -D 32bit -D HXCPP_M32
echo.
echo Compress the contents into a zip file named Inflation-Roulette_<VERSION_NAME>_Mac32
pause
pwd
explorer.exe export\32bit\mac\bin