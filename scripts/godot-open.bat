@echo off
REM Pokreni iz Cursor terminala: .\scripts\godot-open.ps1
REM (bat samo wrapper — preferiraj PowerShell komandu iznad)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0godot-open.ps1" %*
