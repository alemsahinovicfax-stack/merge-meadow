@echo off
REM Pokreni igru jednom (play prozor) iz Cursor terminala ili dvostrukim klikom.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0godot-run.ps1" %*
