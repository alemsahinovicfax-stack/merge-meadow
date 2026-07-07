# Merge Meadow — pokreni Godot 4.7 u OpenGL modu (HP AMD integrisana grafika).
# PREPORUČENO: Cursor terminal → .\scripts\godot-open.ps1
# Auto-restart na promjenu koda: .\scripts\godot-watch.ps1
# Izbjegavaj dvostruki klik na Godot exe (Vulkan ne radi na ovom laptopu).

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"
if (Test-Path (Get-GameProjectPath)) {
    Invoke-GodotImport
}
Start-GodotForeground -ExtraArgs $args
