@echo off
cd /d "%~dp0"
set FLUTTER=C:\src\flutter\bin\flutter.bat
if not exist "%FLUTTER%" set FLUTTER=flutter
echo Building SalaryQuest debug APK... (log: build_log.txt)
echo === START %DATE% %TIME% === > build_log.txt
echo === PUB GET === >> build_log.txt
call "%FLUTTER%" pub get >> build_log.txt 2>&1
echo === ANALYZE === >> build_log.txt
call "%FLUTTER%" analyze --no-fatal-infos --no-fatal-warnings >> build_log.txt 2>&1
echo ANALYZE_EXIT=%ERRORLEVEL% >> build_log.txt
echo === BUILD APK DEBUG === >> build_log.txt
call "%FLUTTER%" build apk --debug >> build_log.txt 2>&1
echo BUILD_EXIT=%ERRORLEVEL% >> build_log.txt
echo === TEST === >> build_log.txt
call "%FLUTTER%" test >> build_log.txt 2>&1
echo TEST_EXIT=%ERRORLEVEL% >> build_log.txt
echo === DONE %DATE% %TIME% === >> build_log.txt
echo Done. You can close this window.
