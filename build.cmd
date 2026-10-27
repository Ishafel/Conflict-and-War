@echo off
setlocal
where pwsh.exe >nul 2>nul
if errorlevel 1 (
    powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0scripts\windows-build.ps1" %*
) else (
    pwsh.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0scripts\windows-build.ps1" %*
)
exit /b %errorlevel%
