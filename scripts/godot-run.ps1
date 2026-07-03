# Merge Meadow — pokreni IGRU jednom (play prozor), bez watch-a.
# Cursor terminal: .\scripts\godot-run.ps1
# Editor umjesto igre: .\scripts\godot-run.ps1 -Editor
# Ovo je ono što agent poziva JEDNOM na kraju sesije (ne restart po izmjeni).

param(
    [switch]$Editor
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

# Ugasi eventualni prethodni Godot da ne ostane duplikat prozora.
Stop-GodotProcess
Start-Sleep -Milliseconds 300

if ($Editor) {
    Start-GodotEditor
} else {
    Start-GodotPlay
}
