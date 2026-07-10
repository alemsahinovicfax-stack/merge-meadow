# Capture Android emulator screenshot for Play Store assets.
# Usage: .\scripts\capture-store-screenshot.ps1 -Name "01-run-lane"
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$OutDir = "marketing/store/screenshots"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$destDir = Join-Path $repoRoot $OutDir
$destFile = Join-Path $destDir "$Name.png"

$adbCandidates = @(
    (Get-Command adb -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
)
$adb = $adbCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $adb) {
    Write-Error "adb not found. Install Android SDK platform-tools or add adb to PATH."
}

$devices = & $adb devices | Select-String "device$"
if (-not $devices) {
    Write-Error "No Android device/emulator connected. Start Pixel_4_API33 first."
}

New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$p = Start-Process -FilePath $adb -ArgumentList @("exec-out", "screencap", "-p") `
    -RedirectStandardOutput $destFile -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) {
    Write-Error "adb screencap failed (exit $($p.ExitCode))."
}

Write-Host "[capture] Saved $destFile"
