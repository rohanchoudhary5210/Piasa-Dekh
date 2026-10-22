@echo off
set "FFMPEG_BIN=C:\Users\Asus\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.2-full_build\bin"
set "PATH=%FFMPEG_BIN%;%PATH%"
cd /d "%~dp0\composition"
echo [render] Starting hyperframes render with FFmpeg...
npx hyperframes render --output ../brag.mp4
