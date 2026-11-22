@echo off
rem Double-click to build the site into docs\ and open it in the browser.
rem (Extra arguments are passed to build.ps1, e.g. build.bat -SiteUrl https://user.github.io/repo)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*
if errorlevel 1 (
  echo.
  echo Build failed. See the messages above.
  pause
  exit /b 1
)
start "" "%~dp0docs\index.html"
echo.
pause
