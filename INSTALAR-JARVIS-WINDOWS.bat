@echo off
REM ==========================================================
REM  Instalador do Jarvis (OpenJarvis) para Windows
REM  De dois cliques neste arquivo e siga as instrucoes.
REM ==========================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\jarvis-br\instalar-windows.ps1" %*
echo.
pause
