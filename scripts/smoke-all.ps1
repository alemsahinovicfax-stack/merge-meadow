# Svi headless smoke testovi (game/scripts/dev/*_smoke.gd), paralelno.
# Svaki radnik ima svoj APPDATA (kopija user:// foldera) — pravi save se ne dira, pa je
# sigurno i prekinuti test koji visi. Settings u kopiji: reduce_motion = false (animacije rade).
#   .\scripts\smoke-all.ps1                 # svi, 4 radnika
#   .\scripts\smoke-all.ps1 -Filter iap     # samo oni čije ime sadrži "iap"
#   .\scripts\smoke-all.ps1 -Workers 2 -TimeoutSec 600
# Prolaz = exit 0 + "<ime> OK" u ispisu + nema "SCRIPT ERROR" / "Parse Error".

param(
    [int]$Workers = 4,
    [int]$TimeoutSec = 420,
    [string]$Filter = ""
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\godot-lib.ps1"

$godot = Get-GodotConsoleExecutable
$gameDir = Get-GameDir
$smokes = @(Get-ChildItem (Join-Path $gameDir "scripts\dev") -Filter "*_smoke.gd" |
    Where-Object { -not $Filter -or $_.BaseName -match $Filter } | Sort-Object Name)
if ($smokes.Count -eq 0) { throw "Nema smoke testova za filter '$Filter'." }

$runRoot = Join-Path ([IO.Path]::GetTempPath()) ("mm_smokes_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
$userSrc = Join-Path $env:APPDATA "Godot\app_userdata\Merge Meadow"
New-Item -ItemType Directory -Force $runRoot | Out-Null

function New-WorkerAppData([int]$i) {
    $appdata = Join-Path $runRoot "appdata_$i"
    $dst = Join-Path $appdata "Godot\app_userdata\Merge Meadow"
    New-Item -ItemType Directory -Force $dst | Out-Null
    if (Test-Path $userSrc) {
        Get-ChildItem $userSrc -File | Where-Object { $_.Extension -in ".json", ".cfg" } |
            ForEach-Object { Copy-Item $_.FullName $dst }
    }
    $settings = Join-Path $dst "settings.cfg"
    if (Test-Path $settings) {
        (Get-Content $settings) -replace '^reduce_motion\s*=.*$', 'reduce_motion=false' | Set-Content $settings -Encoding ascii
    }
    # Editor settings i export templateovi ostaju dostupni (Godot ih čita iz APPDATA\Godot).
    return $appdata
}

$appdatas = @(for ($i = 0; $i -lt $Workers; $i++) { New-WorkerAppData $i })
$queue = New-Object System.Collections.Queue
$smokes | ForEach-Object { $queue.Enqueue($_) }
$running = @{}
$results = New-Object System.Collections.Generic.List[object]
$started = Get-Date

Write-Host "[smoke] $($smokes.Count) testova, $Workers radnika, log: $runRoot"
while ($queue.Count -gt 0 -or $running.Count -gt 0) {
    for ($w = 0; $w -lt $Workers; $w++) {
        if ($running.ContainsKey($w) -or $queue.Count -eq 0) { continue }
        $smoke = $queue.Dequeue()
        $out = Join-Path $runRoot "$($smoke.BaseName).log"
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $godot
        $psi.Arguments = "--headless --rendering-driver opengl3 --path `"$gameDir`" --script res://scripts/dev/$($smoke.Name)"
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        $psi.EnvironmentVariables["APPDATA"] = $appdatas[$w]
        $proc = New-Object System.Diagnostics.Process
        $proc.StartInfo = $psi
        [void]$proc.Start()
        $running[$w] = @{
            Proc = $proc; Smoke = $smoke; Out = $out; Start = Get-Date
            StdOut = $proc.StandardOutput.ReadToEndAsync(); StdErr = $proc.StandardError.ReadToEndAsync()
        }
    }
    Start-Sleep -Milliseconds 400
    foreach ($w in @($running.Keys)) {
        $r = $running[$w]
        $timedOut = ((Get-Date) - $r.Start).TotalSeconds -gt $TimeoutSec
        if (-not $r.Proc.HasExited -and -not $timedOut) { continue }
        if ($timedOut -and -not $r.Proc.HasExited) { try { $r.Proc.Kill() } catch {} ; $r.Proc.WaitForExit(5000) | Out-Null }
        $text = $r.StdOut.Result + "`n" + $r.StdErr.Result
        Set-Content -Path $r.Out -Value $text -Encoding utf8
        $name = $r.Smoke.BaseName
        $ok = (-not $timedOut) -and $r.Proc.ExitCode -eq 0 -and ($text -match [regex]::Escape("$name OK")) -and
            ($text -notmatch "SCRIPT ERROR|Parse Error")
        $why = if ($timedOut) { "timeout" } elseif ($r.Proc.ExitCode -ne 0) { "exit $($r.Proc.ExitCode)" } elseif ($text -match "SCRIPT ERROR|Parse Error") { "script error" } elseif (-not $ok) { "no OK line" } else { "" }
        $sec = [int]((Get-Date) - $r.Start).TotalSeconds
        $results.Add([pscustomobject]@{ Name = $name; Ok = $ok; Why = $why; Sec = $sec; Log = $r.Out })
        Write-Host ("  {0} {1} ({2}s) {3}" -f ($(if ($ok) { "OK  " } else { "FAIL" })), $name, $sec, $why)
        $running.Remove($w)
    }
}

$failed = @($results | Where-Object { -not $_.Ok })
$mins = [math]::Round(((Get-Date) - $started).TotalMinutes, 1)
Write-Host "[smoke] $($results.Count - $failed.Count)/$($results.Count) OK za $mins min."
if ($failed.Count -gt 0) {
    Write-Host "[smoke] Pali (logovi u $runRoot):"
    $failed | ForEach-Object { Write-Host "  $($_.Name): $($_.Why)" }
    exit 1
}
exit 0
