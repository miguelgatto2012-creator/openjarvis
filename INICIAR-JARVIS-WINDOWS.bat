@echo off
REM ==========================================================
REM  Inicia o Jarvis (OpenJarvis) no Windows
REM  Rode INSTALAR-JARVIS-WINDOWS.bat uma vez antes.
REM ==========================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\jarvis-br\iniciar-windows.ps1" %*
echo.
pause
