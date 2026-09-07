# Merge Meadow — pokreni GUT test suite headless, jednom, pa izađi.
# Cursor/Claude terminal: .\scripts\gut-run.ps1
# Koristi game/.gutconfig.json (dirs: res://test/unit). Exit kod != 0 znači pao neki test.

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$godot = Get-GodotExecutable
$gameDir = Get-GameDir

Write-Host "[gut] Running GUT suite (headless)..."
& $godot --headless --rendering-driver opengl3 --path $gameDir -s res://addons/gut/gut_cmdln.gd -gexit
exit $LASTEXITCODE
