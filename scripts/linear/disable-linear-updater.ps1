$ErrorActionPreference = "Stop"

function Resolve-LinearInstallDir {
    if ($args.Count -gt 0 -and $args[0]) {
        return (Resolve-Path -LiteralPath $args[0]).Path
    }

    $scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE "scoop" }
    $current = Join-Path $scoopRoot "apps\linear\current"
    if (Test-Path -LiteralPath $current) {
        return (Resolve-Path -LiteralPath $current).Path
    }

    $appRoot = Join-Path $scoopRoot "apps\linear"
    if (Test-Path -LiteralPath $appRoot) {
        $latest = Get-ChildItem -LiteralPath $appRoot -Directory |
            Where-Object { $_.Name -ne "current" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($latest) { return $latest.FullName }
    }

    throw "Linear installation was not found. Pass the install directory as the first argument."
}

Get-Process -Name "Linear" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

$installDir = Resolve-LinearInstallDir @args
$yaml = Join-Path $installDir "resources\app-update.yml"
if (!(Test-Path -LiteralPath $yaml)) {
    throw "Updater config was not found: $yaml"
}

$content = Get-Content -LiteralPath $yaml -Encoding ASCII | ForEach-Object {
    if ($_.StartsWith("url")) {
        "$($_.Replace("url", "# url")) # Disabled by Scoop"
    } else {
        $_
    }
}
Set-Content -LiteralPath $yaml -Value $content -Encoding ASCII

$updaterPath = Join-Path $env:LOCALAPPDATA "@lineardesktop-updater"
Remove-Item -LiteralPath $updaterPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Disabled Linear updater config: $yaml"
Write-Host "Removed updater cache: $updaterPath"
