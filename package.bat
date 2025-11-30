@echo off
echo Packaging bacman game...
echo.

REM Create a temporary directory
if exist bacman_temp rmdir /s /q bacman_temp
mkdir bacman_temp

REM Copy all game files (excluding todo.txt and this script)
copy conf.lua bacman_temp\ >nul
copy main.lua bacman_temp\ >nul
copy maze.lua bacman_temp\ >nul
copy renderer.lua bacman_temp\ >nul
copy setup.lua bacman_temp\ >nul
copy logo.png bacman_temp\ >nul
xcopy sounds bacman_temp\sounds\ /E /I /Q >nul

REM Create the .love file (it's just a zip file)
cd bacman_temp
powershell Compress-Archive -Path * -DestinationPath ..\bacman.love -Force
cd ..

REM Clean up
rmdir /s /q bacman_temp

echo.
echo Done! Created bacman.love
echo Users can open this with Love2D installed, or drag it onto love.exe
pause

