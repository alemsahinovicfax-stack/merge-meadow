# Headless Android export (Gradle build) - debug APK, release APK (emulator) ili release AAB (Play).
# Primjeri:
#   .\scripts\android-export.ps1 -Preset Aab      -> game\export\android\merge_meadow.aab
#   .\scripts\android-export.ps1 -Preset Apk      -> game\export\android\merge_meadow_release.apk
#   .\scripts\android-export.ps1 -Preset Debug    -> game\merge_meadow_debug.apk
# Release potpis: env GODOT_ANDROID_KEYSTORE_RELEASE_PATH/_USER/_PASSWORD, inače
# game\export_credentials\android_release.local.cfg (gitignore; pravi ga keystore korak, vidi credentials.local.md).

param(
    [ValidateSet("Aab", "Apk", "Debug")]
    [string]$Preset = "Aab"
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
$outPath = Join-Path $gameDir $p.Out
New-Item -ItemType Directory -Force (Split-Path $outPath -Parent) | Out-Null
if (Test-Path $outPath) { Remove-Item $outPath -Force }

function Get-GodotConsoleExecutable {
    # Console varijanta piše log u stdout (GUI exe ga na Windowsu gubi).
    $gui = Get-GodotExecutable
    $candidates = @(@(
        ($gui -replace '\.exe$', '_console.exe'),
        "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe"
    ) | Where-Object { $_ -and (Test-Path $_ -PathType Leaf) })
    if ($candidates) { return $candidates[0] }
    return $gui
}

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
    $proj = Get-Content (Get-GameProjectPath) -Raw
    if ($proj -match 'ca-app-pub-3940256099942544~') {
        Write-Warning "AdMob App ID je još Googleov TEST ID (project.godot admob/general/android/app_id) - upiši produkcijski prije Play production releasea."
    }
}

$godot = Get-GodotConsoleExecutable
$mode = if ($p.Release) { "--export-release" } else { "--export-debug" }
$log = Join-Path $gameDir "export\android\export_$($Preset.ToLower()).log"
New-Item -ItemType Directory -Force (Split-Path $log -Parent) | Out-Null

Write-Host "[android] $($p.Name) -> $outPath"
Write-Host "[android] Godot: $godot"
$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& $godot --headless --path $gameDir --install-android-build-template $mode $p.Name $outPath 2>&1 |
    Tee-Object -FilePath $log | Where-Object { $_ -match 'ERROR|error:|FAILED|BUILD|savepack|Export' } | ForEach-Object { Write-Host "  $_" }
$code = $LASTEXITCODE
$ErrorActionPreference = $prevEap

if ($p.Release) {
    Remove-Item Env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD -ErrorAction SilentlyContinue
}

if ($code -ne 0 -or -not (Test-Path $outPath)) {
    throw "Export nije uspio (exit $code). Log: $log"
}
$mb = [math]::Round((Get-Item $outPath).Length / 1MB, 1)
Write-Host "[android] OK - $outPath ($mb MB). Log: $log"
