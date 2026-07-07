# Samo import asseta (PNG/SVG) — pokreni nakon što dodaš fajl u game/assets/
# Cursor: .\scripts\godot-import.ps1

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"
Invoke-GodotImport
Write-Host "[godot] Import gotov."
