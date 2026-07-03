# Merge Meadow — auto-restart Godot kad se promijeni kod u game/
# Cursor terminal: .\scripts\godot-watch.ps1
# Editor umjesto play prozora: .\scripts\godot-watch.ps1 -Editor
# Zaustavi: Ctrl+C u terminalu

param(
    [switch]$Editor,
    [string]$Scene = "",
    [int]$DebounceMs = 900
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$gameDir = Get-GameDir
if (-not (Test-Path $gameDir)) {
    Write-Error "game/ folder ne postoji: $gameDir"
}

$sync = [hashtable]::Synchronized(@{
    LastChange = [datetime]::MinValue
})

function Invoke-GodotRestart {
    $mode = if ($Editor) { "editor" } else { "play" }
    Write-Host ""
    Write-Host ('[watch] Restart (' + $mode + ') - ' + (Get-Date -Format 'HH:mm:ss')) -ForegroundColor Cyan
    Stop-GodotProcess
    Start-Sleep -Milliseconds 400
    if ($Editor) {
        Start-GodotEditor
    } else {
        Start-GodotPlay -Scene $Scene
    }
}

function Register-GameWatcher {
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $gameDir
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    $watcher.NotifyFilter = [IO.NotifyFilters]::FileName -bor [IO.NotifyFilters]::LastWrite

    $onChange = {
        $path = $Event.SourceEventArgs.FullPath
        if ($path -match '[\\/]\.godot[\\/]') { return }
        if ($path -match '[\\/]\.import[\\/]') { return }
        if ($path -notmatch '\.(gd|tscn|godot|cfg|svg)$') { return }
        Write-Host ('[watch] Promjena: ' + $path) -ForegroundColor Yellow
        $Event.MessageData.LastChange = Get-Date
    }

    Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier "GodotWatchChanged" -MessageData $sync -Action $onChange | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier "GodotWatchCreated" -MessageData $sync -Action $onChange | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName Renamed -SourceIdentifier "GodotWatchRenamed" -MessageData $sync -Action $onChange | Out-Null

    return $watcher
}

Write-Host '=== Godot watch - Merge Meadow ===' -ForegroundColor Green
Write-Host ('Pratim: ' + $gameDir)
Write-Host ('Mod: ' + $(if ($Editor) { 'Editor' } else { if ($Scene) { "Play ($Scene)" } else { 'Play (main scene)' } }))
Write-Host ('Debounce: ' + $DebounceMs + 'ms | Zaustavi: Ctrl+C')
Write-Host ""

Invoke-GodotRestart
$watcher = Register-GameWatcher

try {
    while ($true) {
        if ($sync.LastChange -ne [datetime]::MinValue) {
            $elapsed = ((Get-Date) - $sync.LastChange).TotalMilliseconds
            if ($elapsed -ge $DebounceMs) {
                $sync.LastChange = [datetime]::MinValue
                Invoke-GodotRestart
            }
        }
        Start-Sleep -Milliseconds 200
    }
} finally {
    Write-Host ""
    Write-Host '[watch] Zaustavljam...' -ForegroundColor Yellow
    Stop-GodotProcess
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Get-EventSubscriber | Unregister-Event -ErrorAction SilentlyContinue
}
