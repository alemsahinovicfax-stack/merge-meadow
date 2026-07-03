# Zajednička logika za godot-open.ps1 i godot-watch.ps1

function Get-RepoRoot {
    return Split-Path -Parent $PSScriptRoot
}

function Get-GodotExecutable {
    $candidates = @(
        $env:GODOT_PATH,
        "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe",
        "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe",
        "C:\Godot\Godot_v4.7-stable_win64.exe"
    ) | Where-Object { $_ -and (Test-Path $_) }

    if (-not $candidates) {
        throw @"
Godot exe nije pronađen. Postavi putanju:
  `$env:GODOT_PATH = 'C:\putanja\Godot_v4.7-stable_win64.exe'
ili kopiraj exe u Desktop ili C:\Godot\
"@
    }
    return $candidates[0]
}

function Get-GameProjectPath {
    return Join-Path (Get-RepoRoot) "game\project.godot"
}

function Get-GameDir {
    return Join-Path (Get-RepoRoot) "game"
}

function Test-WatchedGameFile {
    param([string]$Path)
    if ($Path -match '[\\/]\.godot[\\/]') { return $false }
    if ($Path -match '[\\/]\.import[\\/]') { return $false }
    return $Path -match '\.(gd|tscn|godot|cfg|svg)$'
}

function Stop-GodotProcess {
    $names = @(
        "Godot_v4.7-stable_win64",
        "Godot_v4.7-stable_win64_console"
    )
    foreach ($name in $names) {
        Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

function Get-GodotBaseArgs {
    # Relativna putanja "game" (bez razmaka) + radni direktorij = repo root.
    # Start-Process ne citira ArgumentList, pa izbjegavamo razmak iz "Mobilna igra".
    return @("--rendering-driver", "opengl3", "--path", "game")
}

function Start-GodotEditor {
    $godot = Get-GodotExecutable
    $godotArgs = @(Get-GodotBaseArgs)
    Write-Host "[godot] Editor: $godot"
    Write-Host "[godot] Project: $(Get-GameProjectPath)"
    Start-Process -FilePath $godot -ArgumentList $godotArgs -WorkingDirectory (Get-RepoRoot)
}

function Start-GodotPlay {
    param([string]$Scene = "res://scenes/run/run_scene.tscn")

    $godot = Get-GodotExecutable
    $godotArgs = @(Get-GodotBaseArgs) + $Scene
    Write-Host "[godot] Play: $Scene"
    Write-Host "[godot] Exe: $godot"
    Start-Process -FilePath $godot -ArgumentList $godotArgs -WorkingDirectory (Get-RepoRoot)
}

function Start-GodotForeground {
  param([string[]]$ExtraArgs = @())

    $godot = Get-GodotExecutable
    $godotArgs = @("--rendering-driver", "opengl3")
    if ($ExtraArgs.Count -gt 0) {
        $godotArgs += $ExtraArgs
    } elseif (Test-Path (Get-GameProjectPath)) {
        $godotArgs += "--path", (Get-GameDir)
        Write-Host "Project: $(Get-GameProjectPath)"
    }
    Write-Host "Godot (OpenGL): $godot"
    & $godot @godotArgs
}
