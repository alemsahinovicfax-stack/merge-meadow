@echo off
REM Auto-restart igre kad se promijeni kod u game/
REM Play prozor (default): dvostruki klik ili terminal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0godot-watch.ps1" %*
