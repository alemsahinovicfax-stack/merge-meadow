# Merge Meadow — pokreni Godot 4.7 u OpenGL modu (HP AMD integrisana grafika).
# PREPORUČENO: Cursor terminal → .\scripts\godot-open.ps1
# Izbjegavaj dvostruki klik na Godot exe (Vulkan ne radi na ovom laptopu).
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
$repoRoot = Split-Path -Parent $PSScriptRoot
$defaultProject = Join-Path $repoRoot "game\project.godot"

$godotArgs = @("--rendering-driver", "opengl3")
if ($args.Count -gt 0) {
    $godotArgs += $args
} elseif (Test-Path $defaultProject) {
    $godotArgs += "--path", (Join-Path $repoRoot "game")
    Write-Host "Project: $defaultProject"
}

Write-Host "Godot (OpenGL): $godot"
& $godot @godotArgs
