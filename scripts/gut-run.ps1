# Merge Meadow — pokreni GUT test suite headless, jednom, pa izađi.
# Cursor/Claude terminal: .\scripts\gut-run.ps1
# Koristi game/.gutconfig.json (dirs: res://test/unit). Exit kod != 0 znači pao neki test.

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$godot = Get-GodotExecutable
$gameDir = Get-GameDir

Write-Host "[gut] Running GUT suite (headless)..."
# GUT sam vraca 0 i kad test padne (2026-11-14: kapija je propustila build s jednim palim testom),
# pa se ishod cita i iz ispisa.
$failed = $false
& $godot --headless --rendering-driver opengl3 --path $gameDir -s res://addons/gut/gut_cmdln.gd -gexit | ForEach-Object {
    $line = "$_"
    if ($line -match '----\s*\d+\s+failing tests\s*----' -or $line -match 'Failing Tests\s+[1-9]') { $failed = $true }
    Write-Output $line
}
$code = $LASTEXITCODE
if ($failed -and $code -eq 0) { $code = 1 }
exit $code
