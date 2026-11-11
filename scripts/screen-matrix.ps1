# Slike svih stranica huba na matrici omjera ekrana (telefoni + tableti) - FIX-TEL.
# Otvara kratke prozore igre (ne headless: treba pravo crtanje), save ide na kopiju.
#   .\scripts\screen-matrix.ps1                 # sva matrica
#   .\scripts\screen-matrix.ps1 -Only 20x9      # samo jedan omjer
# Slike: %TEMP%\mm_matrix\<omjer>_<stranica>.png

param([string]$Only = "", [string]$Out = "")

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$godot = Get-GodotConsoleExecutable
$gameDir = Get-GameDir
if (-not $Out) { $Out = Join-Path ([IO.Path]::GetTempPath()) "mm_matrix" }
New-Item -ItemType Directory -Force $Out | Out-Null

# Logička veličina (px baze) -> prozor skaliran da stane na laptop (visina 900).
$matrix = [ordered]@{
    "16x9"     = @(1080, 1920)
    "19.5x9"   = @(1080, 2340)
    "20x9"     = @(1080, 2400)
    "21x9"     = @(1080, 2520)
    "tab16x10" = @(1200, 1920)
    "tab4x3"   = @(1440, 1920)
}

$appdata = Join-Path $Out "appdata"
$dst = Join-Path $appdata "Godot\app_userdata\Merge Meadow"
New-Item -ItemType Directory -Force $dst | Out-Null
$userSrc = Join-Path $env:APPDATA "Godot\app_userdata\Merge Meadow"
if (Test-Path $userSrc) {
    Get-ChildItem $userSrc -File | Where-Object { $_.Extension -in ".json", ".cfg" -and $_.Name -notin "dev_flags.cfg", "ads_debug.cfg" } |
        ForEach-Object { Copy-Item $_.FullName $dst -Force }
}
$env:APPDATA = $appdata
$env:MM_OUT = $Out

$prevEap = $ErrorActionPreference
foreach ($tag in $matrix.Keys) {
    if ($Only -and $tag -ne $Only) { continue }
    $w = $matrix[$tag][0]; $h = $matrix[$tag][1]
    $scale = 900.0 / $h
    $res = "{0}x{1}" -f [int]($w * $scale), [int]($h * $scale)
    $env:MM_TAG = $tag
    Write-Host "[matrix] $tag ($w x $h) prozor $res"
    $ErrorActionPreference = "Continue"
    & $godot --rendering-driver opengl3 --path $gameDir --resolution $res --script res://scripts/dev/screen_matrix_capture.gd 2>&1 |
        Where-Object { $_ -match 'ERROR|captured|OK$' } | ForEach-Object { Write-Host "  $_" }
    $ErrorActionPreference = $prevEap
}
Write-Host "[matrix] slike: $Out"
