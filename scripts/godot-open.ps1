# Merge Meadow — pokreni Godot 4.7 u OpenGL modu (HP AMD integrisana grafika).
# Dvostruki klik ili: .\scripts\godot-open.ps1
# Opcionalno: $env:GODOT_PATH = "C:\putanja\Godot_v4.7-stable_win64.exe"

$ErrorActionPreference = "Stop"

$candidates = @(
    $env:GODOT_PATH,
    "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe",
    "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe",
    "C:\Godot\Godot_v4.7-stable_win64.exe"
) | Where-Object { $_ -and (Test-Path $_) }

if (-not $candidates) {
    Write-Error @"
Godot exe nije pronađen. Postavi putanju:
  `$env:GODOT_PATH = 'C:\putanja\Godot_v4.7-stable_win64.exe'
ili kopiraj exe u Desktop ili C:\Godot\
"@
}

$godot = $candidates[0]
Write-Host "Godot (OpenGL): $godot"
& $godot --rendering-driver opengl3 @args
