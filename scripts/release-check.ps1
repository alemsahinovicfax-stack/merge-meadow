# KAPIJA prije svakog uploada na Google Play (FIX-TEL 2026-11).
# Pravi AAB i pada na PRVOJ grešci. Upload ide samo kad na kraju piše "RELEASE OK".
# Zašto postoji: build 1.0.1 (code 10) je otišao na Play bez skinova i Nibbsa, s rasporedom
# za jedan omjer ekrana i skrolom koji ne radi prstom - ništa od toga se nije vidjelo u editoru.
#
#   .\scripts\release-check.ps1              # sve: testovi + testovi iz paketa + AAB
#   .\scripts\release-check.ps1 -Matrix      # + slike svih stranica na 6 omjera (otvara prozore)
#   .\scripts\release-check.ps1 -SkipSmokes  # samo za probu skripte - NE za pravi upload
#
# Koraci:
#   1. kopije SVG teksta + svg_source_smoke          (fajl koji export ne nosi)
#   2. GUT + svi smoke testovi (tvoj save, pali ponovo na čistom)  (regresije logike)
#   3. export paketa + smoke testovi IZ PAKETA       (radi u editoru, ne radi u buildu)
#   4. version code > zadnji u play-uploads.md        (Play odbija isti code)
#   5. AAB + provjera sadržaja                        (SVG tekst, data JSON, bez test fajlova)
#   6. lista "provjeri rukom na telefonu"

param(
    [switch]$Matrix,
    [switch]$SkipSmokes
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$repo = Get-RepoRoot
$gameDir = Get-GameDir
$started = Get-Date

function Step([string]$title) { Write-Host ""; Write-Host "=== $title ===" -ForegroundColor Cyan }
function Fail([string]$msg) { Write-Host ""; Write-Host "RELEASE BLOCKED: $msg" -ForegroundColor Red; exit 1 }
function Run([string]$script, [string[]]$scriptArgs = @()) {
    # Out-Host: ispis pod-skripte ide na ekran, a funkcija vraca SAMO exit kod.
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot $script) @scriptArgs | Out-Host
    return $LASTEXITCODE
}

# Smoke testovi koji se pokreću IZ PAKETA (ne čitaju ništa iz projekta na disku).
# (phone_playtest_smoke nije ovdje: cita export_presets.cfg, kojeg u paketu nema.)
$packSmokes = @("svg_source_smoke", "touch_scroll_smoke", "shop_open_smoke")

# Stari AAB se brise na pocetku pravog prolaza: ako kapija padne, u folderu ne ostaje
# merge_meadow.aab od ranije koji izgleda kao da je prosao.
if (-not $SkipSmokes) {
    Remove-Item (Join-Path $gameDir "export\android\merge_meadow.aab") -Force -ErrorAction SilentlyContinue
}

Step "1/6 SVG tekst za export"
if ((Run "sync-svg-src.ps1") -ne 0) { Fail "sync-svg-src.ps1 nije uspio." }
if ((Run "smoke-all.ps1" @("-Filter", "svg_source", "-CleanSave")) -ne 0) { Fail "svg_source_smoke pada - skinovi / Nibbs ne bi postojali u buildu." }

Step "2/6 GUT + smoke testovi"
if ($SkipSmokes) {
    Write-Warning "Smoke testovi PRESKOČENI (-SkipSmokes) - ovaj prolaz ne vrijedi za upload."
} else {
    # GUT pise u user:// (test atomarnog savea) - na kopiju, ne na pravi save igraca.
    $realAppData = $env:APPDATA
    $gutAppData = Join-Path ([IO.Path]::GetTempPath()) "mm_release_gut_appdata"
    New-Item -ItemType Directory -Force (Join-Path $gutAppData "Godotpp_userdata\Merge Meadow") | Out-Null
    $env:APPDATA = $gutAppData
    $gutCode = Run "gut-run.ps1"
    $env:APPDATA = $realAppData
    if ($gutCode -ne 0) { Fail "GUT testovi padaju." }
    # Smoke testovi zavise od savea (stanje 2026-11-11): dio trazi napredak igraca, dio cist
    # save. Zato dva prolaza: kopija tvog savea, pa samo pali jos jednom na cistom saveu.
    # Build obara samo test koji padne u OBA. Otvoren zadatak: testovi s vlastitim saveom.
    $smokeOut = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "smoke-all.ps1") 2>&1 | Out-String
    Write-Host $smokeOut
    if ($LASTEXITCODE -ne 0) {
        $failed = @([regex]::Matches($smokeOut, '(?m)^\s*FAIL\s+(\S+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
        if ($failed.Count -eq 0) { Fail "smoke-all.ps1 je pao bez liste testova." }
        Write-Host "  Ponavljam na cistom saveu: $($failed -join ', ')"
        $filter = "^(" + ($failed -join "|") + ")$"
        $retryOut = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "smoke-all.ps1") -CleanSave -Workers 2 -Filter $filter 2>&1 | Out-String
        Write-Host $retryOut
        if ($LASTEXITCODE -ne 0) {
            $still = @([regex]::Matches($retryOut, '(?m)^\s*FAIL\s+(\S+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
            Fail "Smoke testovi padaju i s tvojim i s cistim saveom: $($still -join ', ')"
        }
        Write-Host "  Svi pali testovi prolaze na cistom saveu (zavise od savea, nisu regresija)."
    }
}

Step "3/6 Testovi iz exportovanog paketa"
$first = $true
foreach ($smoke in $packSmokes) {
    $packArgs = @("-Smoke", $smoke)
    if (-not $first) { $packArgs += "-NoExport" }
    $first = $false
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "phone-like-run.ps1") @packArgs 2>&1 | Out-String
    $spaced = $smoke -replace '_', ' '
    if ($out -notmatch ("(" + [regex]::Escape($smoke) + "|" + [regex]::Escape($spaced) + ") OK") -or $out -match "SCRIPT ERROR|Parse Error") {
        Write-Host $out
        Fail "$smoke pada kad se igra pokrene IZ PAKETA - na telefonu bi bilo isto."
    }
    Write-Host "  OK   $smoke (iz paketa)"
}

if ($Matrix) {
    Step "Slike na 6 omjera ekrana"
    [void](Run "screen-matrix.ps1")
    Write-Host "  Pregledaj slike prije uploada: $([IO.Path]::GetTempPath())mm_matrix"
}

Step "4/6 Version code"
$presets = Get-Content (Join-Path $gameDir "export_presets.cfg") -Raw
$codes = @([regex]::Matches($presets, '(?m)^version/code=(\d+)') | ForEach-Object { [int]$_.Groups[1].Value } | Sort-Object -Unique)
if ($codes.Count -ne 1) { Fail "Android preseti imaju različit version/code: $($codes -join ', ')." }
$code = $codes[0]
$name = ([regex]::Match($presets, '(?m)^version/name="([^"]+)"')).Groups[1].Value
$uploads = Join-Path $repo "docs\06-production\play-uploads.md"
$lastCode = 0
if (Test-Path $uploads) {
    foreach ($m in [regex]::Matches((Get-Content $uploads -Raw), '(?m)^\|\s*\d{4}-\d{2}-\d{2}\s*\|\s*(\d+)\s*\|')) {
        $lastCode = [math]::Max($lastCode, [int]$m.Groups[1].Value)
    }
}
if ($code -le $lastCode) { Fail "version/code $code nije veći od zadnjeg uploadanog ($lastCode, docs\06-production\play-uploads.md). Podigni ga u export_presets.cfg (sva tri Android preseta)." }
Write-Host "  verzija $name, code $code (zadnji uploadan: $lastCode)"

Step "5/6 AAB + sadržaj"
# android-export.ps1 pravi AAB samo uz MM_RELEASE_GATE=1 (postavlja ga jedino ova skripta).
# Proba (-SkipSmokes) nije prosla testove, pa dobija -NoGate i ime ..._UNCHECKED.aab.
if ($SkipSmokes) {
    $aabArgs = @("-Preset", "Aab", "-NoGate")
    $aab = Join-Path $gameDir "export\android\merge_meadow_UNCHECKED.aab"
} else {
    $aabArgs = @("-Preset", "Aab")
    $aab = Join-Path $gameDir "export\android\merge_meadow.aab"
    $env:MM_RELEASE_GATE = "1"
}
$exportCode = Run "android-export.ps1" $aabArgs
Remove-Item Env:MM_RELEASE_GATE -ErrorAction SilentlyContinue
if ($exportCode -ne 0) { Fail "Export AAB-a nije uspio." }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($aab)
try { $entries = @($zip.Entries | ForEach-Object { $_.FullName }) } finally { $zip.Dispose() }
$dataWant = @(Get-ChildItem (Join-Path $gameDir "data") -Filter "*.json" -File -Recurse | ForEach-Object {
    "data/" + $_.FullName.Substring((Join-Path $gameDir "data").Length + 1).Replace('\', '/') })
$missing = @($dataWant | Where-Object { $rel = $_; -not ($entries | Where-Object { $_.EndsWith("/assets/$rel") }) })
if ($missing.Count -gt 0) { Fail "U AAB-u fale data fajlovi: $($missing -join ', ')" }
$testFiles = @($entries | Where-Object { $_ -match '/assets/(test|addons/gut)/' })
if ($testFiles.Count -gt 0) { Fail "U AAB-u su test fajlovi ($($testFiles.Count), npr. $($testFiles[0])) - dopuni exclude_filter." }
$mb = [math]::Round((Get-Item $aab).Length / 1MB, 1)
Write-Host "  AAB $mb MB, data JSON $($dataWant.Count) / $($dataWant.Count), bez test fajlova"

Step "6/6 Provjeri rukom na telefonu (internal test, ~5 min)"
@(
    "Home: Pip je NOVI (rig), 'Looks' dolje desno, Level Path do dna ekrana",
    "Shop > Looks: skinovi se vide; skrol prstom preko kartica i dugmadi; tap kupuje / javlja 'Need N more coins'",
    "Shop bez coina: prsten tačno oko coin čipa u headeru",
    "Ormar: obuci skin -> isti skin na Homeu i u runu",
    "Run: pređi level -> dugme piše 'Continue'; padni -> 'Retry'",
    "Arena: Nibbs se vidi; sjeme prati prst i spaja se; kraj runde pokaže 'Round over'",
    "Camp: lista i Trade bar do dna; drži Trade - bez štekanja; prazna vreća -> ikona strelice",
    "Journal: ulazak bez zastoja, i poslije novog cvijeta",
    "Okreni kroz svih 5 tabova 3 puta - bez zastoja",
    "Zatvori i otvori igru - napredak je tu"
) | ForEach-Object { Write-Host "  [ ] $_" }

$mins = [math]::Round(((Get-Date) - $started).TotalMinutes, 1)
Write-Host ""
if ($SkipSmokes) {
    Write-Host "PROBA GOTOVA ($mins min) - smoke testovi su preskočeni, ovo NIJE dozvola za upload." -ForegroundColor Yellow
    exit 2
}
Write-Host "RELEASE OK - $aab (verzija $name, code $code, $mins min)" -ForegroundColor Green
Write-Host "Poslije uploada dodaj red u docs\06-production\play-uploads.md."
exit 0
