# Instaliraj debug APK i pokreni Merge Meadow na emulatoru/uredjaju.
# Zahtijeva: adb + bootan emulator (start-android-emulator.ps1).

param(
    [string]$Apk = (Join-Path (Split-Path $PSScriptRoot -Parent) "game\merge_meadow_debug.apk"),
    [string]$Package = "com.mergemeadow.game",
    [string]$Launcher = "com.godot.game.GodotAppLauncher"
)

$ErrorActionPreference = "Stop"
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path $adb)) { throw "adb not found: $adb" }
if (-not (Test-Path $Apk)) { throw "APK missing: $Apk - export Android Debug from Godot." }

Write-Host "[android] Waiting for device..."
$deadline = (Get-Date).AddMinutes(5)
do {
    $boot = try { (& $adb shell getprop sys.boot_completed 2>$null).Trim() } catch { "" }
    if ($boot -eq "1") { break }
    Start-Sleep -Seconds 3
} while ((Get-Date) -lt $deadline)

if ($boot -ne "1") { throw "Emulator did not boot within 5 min." }

Write-Host "[android] Installing APK..."
& $adb install -r $Apk
if ($LASTEXITCODE -ne 0) { throw "adb install failed (exit $LASTEXITCODE)" }

Write-Host "[android] Launching game..."
& $adb shell am force-stop $Package
& $adb shell am start -n "$Package/$Launcher"

Write-Host "[android] Waiting for Godot startup..."
Start-Sleep -Seconds 8
& $adb logcat -c | Out-Null
Start-Sleep -Seconds 5
Write-Host "[android] Logcat (godot):"
& $adb logcat -d -s godot:* Godot:* AndroidRuntime:E 2>&1 | Select-Object -Last 50
