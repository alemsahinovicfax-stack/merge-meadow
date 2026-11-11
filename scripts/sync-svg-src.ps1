# Kopije SVG teksta za export: game\data\svg_src\<putanja>.svgsrc
# Godot u export ne stavlja sirovi .svg koji ima .import, a Pip rig, skinovi i Nibbs
# se rasterizuju iz SVG TEKSTA (game\scripts\visual\svg_source.gd). Pokreni poslije
# svake izmjene SVG-a u folderima ispod; android-export.ps1 ga zove sam.
#   .\scripts\sync-svg-src.ps1

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$gameDir = Get-GameDir
$mirrorRoot = Join-Path $gameDir "data\svg_src"

# Sve što kod čita kao tekst (SvgSource.read): Pip sprite + poze, Pip rig, Nibbs rig.
$sources = @()
$sources += Get-ChildItem (Join-Path $gameDir "assets\sprites") -Filter "pip_*.svg" -File
$sources += Get-ChildItem (Join-Path $gameDir "assets\pip") -Filter "*.svg" -File -Recurse
$sources += Get-ChildItem (Join-Path $gameDir "assets\muncher") -Filter "*.svg" -File -Recurse

$wanted = @{}
$written = 0
foreach ($src in $sources) {
    $rel = $src.FullName.Substring($gameDir.Length + 1)
    $dst = Join-Path $mirrorRoot ([IO.Path]::ChangeExtension($rel, ".svgsrc"))
    $wanted[$dst.ToLower()] = $true
    $bytes = [IO.File]::ReadAllBytes($src.FullName)
    if ((Test-Path $dst) -and [Linq.Enumerable]::SequenceEqual([IO.File]::ReadAllBytes($dst), $bytes)) { continue }
    New-Item -ItemType Directory -Force (Split-Path $dst -Parent) | Out-Null
    [IO.File]::WriteAllBytes($dst, $bytes)
    $written++
}

$removed = 0
if (Test-Path $mirrorRoot) {
    Get-ChildItem $mirrorRoot -Filter "*.svgsrc" -File -Recurse | ForEach-Object {
        if (-not $wanted.ContainsKey($_.FullName.ToLower())) { Remove-Item $_.FullName -Force; $removed++ }
    }
}
Write-Host "[svg-src] $($sources.Count) SVG, upisano $written, obrisano $removed -> $mirrorRoot"
