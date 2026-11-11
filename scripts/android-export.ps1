# Headless Android export (Gradle build) - debug APK, release APK (emulator) ili release AAB (Play).
# Primjeri:
#   .\scripts\android-export.ps1 -Preset Aab      -> game\export\android\merge_meadow.aab
#   .\scripts\android-export.ps1 -Preset Apk      -> game\export\android\merge_meadow_release.apk
#   .\scripts\android-export.ps1 -Preset Debug    -> game\merge_meadow_debug.apk
# Release potpis: env GODOT_ANDROID_KEYSTORE_RELEASE_PATH/_USER/_PASSWORD, inače
# game\export_credentials\android_release.local.cfg (gitignore; pravi ga keystore korak, vidi credentials.local.md).

#
# AAB je ZAKLJUCAN iza kapije: -Preset Aab radi samo kad ga pozove scripts\release-check.ps1
# (ona postavi MM_RELEASE_GATE=1). Rucno, bez provjera:
#   .\scripts\android-export.ps1 -Preset Aab -NoGate  -> game\export\android\merge_meadow_UNCHECKED.aab
# Taj fajl NE ide na Play. Apk i Debug (emulator) nisu zakljucani.

param(
    [ValidateSet("Aab", "Apk", "Debug")]
    [string]$Preset = "Aab",
    [switch]$NoGate
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$repo = Get-RepoRoot
$gameDir = Get-GameDir

$presets = @{
    Aab   = @{ Name = "Android Release AAB"; Out = "export\android\merge_meadow.aab"; Release = $true }
    Apk   = @{ Name = "Android Release APK"; Out = "export\android\merge_meadow_release.apk"; Release = $true }
    Debug = @{ Name = "Android Debug"; Out = "merge_meadow_debug.apk"; Release = $false }
}
$p = $presets[$Preset]
if ($Preset -eq "Aab") {
    # Prije bilo kakvog brisanja: odbijen poziv ne smije dirati postojeci AAB.
    if ($NoGate) {
        $p.Out = "export\android\merge_meadow_UNCHECKED.aab"
        Write-Warning "AAB BEZ KAPIJE (-NoGate): nista nije provjereno. Izlaz je merge_meadow_UNCHECKED.aab i NE ide na Play."
    } elseif ($env:MM_RELEASE_GATE -ne "1") {
        throw "AAB za Play se pravi samo kroz kapiju: .\scripts\release-check.ps1 (testovi + testovi iz paketa + version code + sadrzaj). Za probni AAB bez provjera: -Preset Aab -NoGate."
    }
}
$outPath = Join-Path $gameDir $p.Out
New-Item -ItemType Directory -Force (Split-Path $outPath -Parent) | Out-Null
if (Test-Path $outPath) { Remove-Item $outPath -Force }

if ($p.Release -and -not $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD) {
    $cfg = Join-Path $gameDir "export_credentials\android_release.local.cfg"
    if (-not (Test-Path $cfg)) { throw "Release keystore nije podešen: nema $cfg ni GODOT_ANDROID_KEYSTORE_RELEASE_* env." }
    $kv = @{}
    foreach ($line in Get-Content $cfg) {
        if ($line -match '^\s*([a-z_]+)\s*=\s*(.*)$') { $kv[$Matches[1]] = $Matches[2].Trim() }
    }
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $kv["path"]
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $kv["user"]
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $kv["password"]
}

if ($p.Release) {
    # Googleov test App ID u releaseu = test reklame. OK za internal test, ne za produkciju.
    # Plugin briše postavku kad je jednaka defaultu (test ID), pa "nema postavke" = test.
    $proj = Get-Content (Get-GameProjectPath) -Raw
    if ($proj -notmatch 'general/android/app_id="ca-app-pub-(?!3940256099942544)\d+~\d+"') {
        Write-Warning "AdMob App ID je još Googleov TEST ID (project.godot admob/general/android/app_id) - upiši produkcijski prije Play production releasea."
    }
}

# Kopije SVG teksta (.svgsrc) - bez njih telefon nema skinove ni Nibbsa (greske-katalog #63).
& "$PSScriptRoot\sync-svg-src.ps1"

$godot = Get-GodotConsoleExecutable
$mode = if ($p.Release) { "--export-release" } else { "--export-debug" }
# Template samo kad fali ili je za drugu verziju Godota: ponovna instalacija usred scana
# editora zna oboriti export (exit -1 bez poruke, katalog #55).
$buildVersion = Join-Path $gameDir "android\.build_version"
$installArgs = @()
if (-not (Test-Path $buildVersion) -or (Get-Content $buildVersion -Raw).Trim() -ne "4.7.stable") {
    $installArgs = @("--install-android-build-template")
}
# Gradle daemon naslijedi stdout pipe Godota, pa Godot console omotač nikad ne izađe i drži log
# (sljedeći export: "file is being used by another process", exit -1). Bez daemona build traje
# ~20 s duže, ali skripta se uredno završi.
$env:GRADLE_OPTS = "-Dorg.gradle.daemon=false"
$log = Join-Path $gameDir "export\android\export_$($Preset.ToLower()).log"
New-Item -ItemType Directory -Force (Split-Path $log -Parent) | Out-Null

Write-Host "[android] $($p.Name) -> $outPath"
Write-Host "[android] Godot: $godot"
$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
# --verbose: bez njega Godot ne ispiše Gradle izlaz, pa pad (exit -1) ostaje bez razloga u logu.
& $godot --headless --verbose --path $gameDir @installArgs $mode $p.Name $outPath 2>&1 |
    Tee-Object -FilePath $log | Where-Object { $_ -match 'ERROR|error:|FAILED|BUILD|savepack|Export' } | ForEach-Object { Write-Host "  $_" }
$code = $LASTEXITCODE
$ErrorActionPreference = $prevEap

if ($p.Release) {
    Remove-Item Env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD -ErrorAction SilentlyContinue
}

if ($code -ne 0 -or -not (Test-Path $outPath)) {
    throw "Export nije uspio (exit $code). Log: $log"
}
# Cuvar: paket mora nositi SVG tekst koji kod cita (SvgSource). Ako ga nema, build je neupotrebljiv.
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($outPath)
try { $svgSrc = @($zip.Entries | Where-Object { $_.FullName -like "*data/svg_src/*.svgsrc" }).Count } finally { $zip.Dispose() }
$svgWant = @(Get-ChildItem (Join-Path $gameDir "data\svg_src") -Filter "*.svgsrc" -File -Recurse).Count
if ($svgSrc -lt $svgWant -or $svgWant -eq 0) {
    throw "Export nema SVG tekst: $svgSrc od $svgWant .svgsrc fajlova u paketu (include_filter *.svgsrc u export_presets.cfg)."
}
Write-Host "[android] SVG tekst u paketu: $svgSrc / $svgWant"
$mb = [math]::Round((Get-Item $outPath).Length / 1MB, 1)
Write-Host "[android] OK - $outPath ($mb MB). Log: $log"
