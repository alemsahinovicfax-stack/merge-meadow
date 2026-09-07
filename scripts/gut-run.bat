@echo off
REM Pokreni GUT test suite headless (koristi game/.gutconfig.json).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0gut-run.ps1" %*
