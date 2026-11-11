# Kompjuter kao telefon: igra pokrenuta IZ EXPORTOVANOG PAKETA (bez sirovih fajlova projekta)
# u prozoru s omjerom telefona / tableta. Hvata bugove koje editor ne vidi (FIX-TEL 2026-11):
# fajl koji nije u exportu, visok ili širok ekran.
#   .\scripts\phone-like-run.ps1                       # 1080 x 2400 (20:9), GUI
#   .\scripts\phone-like-run.ps1 -Width 1440 -Height 1920   # tablet 4:3
#   .\scripts\phone-like-run.ps1 -Smoke svg_source_smoke    # headless test iz paketa
#   .\scripts\phone-like-run.ps1 -NoExport             # isti paket kao prošli put
# Save: APPDATA ide na privremenu kopiju - pravi save se ne dira.

param(
    [int]$Width = 1080,
    [int]$Height = 2400,
    [string]$Smoke = "",
    [switch]$NoExport,
    [switch]$RealSave
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$gameDir = Get-GameDir
$godot = Get-GodotConsoleExecutable
$workDir = Join-Path ([IO.Path]::GetTempPath()) "mm_phone_like"
New-Item -ItemType Directory -Force $workDir | Out-Null
$pck = Join-Path $workDir "merge_meadow_phone.pck"

$prevEap = $ErrorActionPreference
if (-not $NoExport -or -not (Test-Path $pck)) {
    & "$PSScriptRoot\sync-svg-src.ps1"
    if (Test-Path $pck) { Remove-Item $pck -Force }
    Write-Host "[phone-like] export paketa -> $pck"
    $ErrorActionPreference = "Continue"
    & $godot --headless --path $gameDir --export-pack "Android Release APK" $pck 2>&1 |
        Tee-Object -FilePath (Join-Path $workDir "export.log") | Where-Object { $_ -match 'ERROR' } | ForEach-Object { Write-Host "  $_" }
    $ErrorActionPreference = $prevEap
    if (-not (Test-Path $pck)) { throw "Export paketa nije uspio. Log: $workDir\export.log" }
}

if (-not $RealSave) {
    $appdata = Join-Path $workDir "appdata"
    $dst = Join-Path $appdata "Godot\app_userdata\Merge Meadow"
    New-Item -ItemType Directory -Force $dst | Out-Null
    $userSrc = Join-Path $env:APPDATA "Godot\app_userdata\Merge Meadow"
    if ((Test-Path $userSrc) -and -not (Get-ChildItem $dst -File -ErrorAction SilentlyContinue)) {
        Get-ChildItem $userSrc -File | Where-Object { $_.Extension -in ".json", ".cfg" } | ForEach-Object { Copy-Item $_.FullName $dst }
    }
    $env:APPDATA = $appdata
}

# Prozor staje na ekran laptopa: visina najviše 900 px, omjer ostaje.
$scale = [math]::Min(1.0, 900.0 / $Height)
$winW = [int]($Width * $scale)
$winH = [int]($Height * $scale)

# Radni folder BEZ project.godot: inače Godot uzme projekat s diska umjesto paketa.
Push-Location $workDir
try {
    $ErrorActionPreference = "Continue"
    if ($Smoke) {
        Write-Host "[phone-like] smoke $Smoke iz paketa"
        & $godot --headless --rendering-driver opengl3 --main-pack $pck --script "res://scripts/dev/$Smoke.gd" 2>&1 | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "[phone-like] igra iz paketa, prozor $winW x $winH (omjer $Width x $Height)"
        & $godot --rendering-driver opengl3 --main-pack $pck --resolution "${winW}x${winH}" 2>&1 |
            Where-Object { $_ -match 'ERROR|WARNING|SCRIPT' } | ForEach-Object { Write-Host "  $_" }
    }
    $code = $LASTEXITCODE
} finally {
    $ErrorActionPreference = $prevEap
    Pop-Location
}
exit $code
