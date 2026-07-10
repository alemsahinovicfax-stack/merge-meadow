# Merge Meadow — pokreni Android emulator za dev/test.
# Godot 4 GL Compatibility zahtijeva OpenGL ES 3.0+.
# API 30 + default GPU = GLES 2 -> crash. Rjesenje: API 33 AVD + SwiftShader.
#
# Usage:
#   .\scripts\start-android-emulator.ps1              # Pixel_4_API33 (preporučeno)
#   .\scripts\start-android-emulator.ps1 -Avd Pixel_4 # legacy API 30 (mora SwiftShader)

param(
    [string]$Avd = "Pixel_4_API33",
    [ValidateSet("swiftshader_indirect", "host", "auto")]
    [string]$Gpu = "host",
    [switch]$NoSnapshot
)

$ErrorActionPreference = "Stop"
$sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$emulator = Join-Path $sdk "emulator\emulator.exe"
$avdmanager = Join-Path $sdk "cmdline-tools\latest\bin\avdmanager.bat"
$sdkmanager = Join-Path $sdk "cmdline-tools\latest\bin\sdkmanager.bat"

if (-not (Test-Path $emulator)) {
    throw "Emulator nije pronađen: $emulator"
}

function Test-SystemImageReady {
    param([string]$ImageId)
    $parts = $ImageId -split ';'
    if ($parts.Count -lt 4) { return $false }
    $path = Join-Path $sdk "system-images\$($parts[1])\$($parts[2])\$($parts[3])"
    return (Test-Path (Join-Path $path "source.properties"))
}

function Ensure-Avd {
    param([string]$Name, [string]$ImageId, [string]$Device = "pixel_4")

    $list = & $avdmanager list avd 2>&1 | Out-String
    if ($list -match "Name: $Name") {
        Write-Host "[emulator] AVD '$Name' postoji."
        return
    }

    if (-not (Test-SystemImageReady $ImageId)) {
        Write-Host "[emulator] System image nije spreman - instaliram $ImageId (moze potrajati)..."
        echo y | & $sdkmanager $ImageId
        if (-not (Test-SystemImageReady $ImageId)) {
            throw "System image nije instaliran: $ImageId"
        }
    }

    Write-Host "[emulator] Kreiram AVD '$Name'..."
    echo no | & $avdmanager create avd -n $Name -k $ImageId -d $Device --force
}

function Get-Api33ImageId {
    $candidates = @(
        "system-images;android-33;google_apis_playstore;x86_64",
        "system-images;android-33;google_apis;x86_64"
    )
    foreach ($id in $candidates) {
        if (Test-SystemImageReady $id) { return $id }
    }
    return $null
}

$api33Image = Get-Api33ImageId
if ($api33Image) {
    Ensure-Avd -Name "Pixel_4_API33" -ImageId $api33Image
    if ($Avd -eq "Pixel_4_API33") { $script:Avd = "Pixel_4_API33" }
} elseif ($Avd -eq "Pixel_4_API33") {
    throw "Pixel_4_API33 trazi API 33 system image. Instaliraj: sdkmanager `"system-images;android-33;google_apis;x86_64`""
} else {
    Write-Host "[emulator] API 33 image nije spreman - koristim Pixel_4 (API 30) + SwiftShader GLES3."
    $Avd = "Pixel_4"
}

# Ugasi prethodni emulator da ne bude port conflict.
Get-Process -Name "qemu-system-x86_64", "emulator" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$emuArgs = @("-avd", $Avd, "-gpu", $Gpu)
if ($NoSnapshot) { $emuArgs += "-no-snapshot-load" }

Write-Host "[emulator] Pokrecem: $Avd (gpu=$Gpu)"
Start-Process -FilePath $emulator -ArgumentList $emuArgs -WorkingDirectory (Split-Path $emulator)
