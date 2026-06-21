$ErrorActionPreference = "Stop"

function Resolve-LMStudioInstallDir {
    if ($args.Count -gt 0 -and $args[0]) {
        return (Resolve-Path -LiteralPath $args[0]).Path
    }

    $scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE "scoop" }
    $current = Join-Path $scoopRoot "apps\lm-studio\current"
    if (Test-Path -LiteralPath $current) {
        return (Resolve-Path -LiteralPath $current).Path
    }

    $appRoot = Join-Path $scoopRoot "apps\lm-studio"
    if (Test-Path -LiteralPath $appRoot) {
        $latest = Get-ChildItem -LiteralPath $appRoot -Directory |
            Where-Object { $_.Name -ne "current" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($latest) { return $latest.FullName }
    }

    throw "LM Studio installation was not found. Pass the install directory as the first argument."
}

Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

$installDir = Resolve-LMStudioInstallDir @args
$yaml = Join-Path $installDir "resources\app-update.yml"
if (!(Test-Path -LiteralPath $yaml)) {
    throw "Updater config was not found: $yaml"
}

$content = Get-Content -LiteralPath $yaml -Encoding ASCII | ForEach-Object {
    if ($_ -match "^(provider|bucket|endpoint):") {
        "# $_ # Disabled by Scoop"
    } else {
        $_
    }
}
Set-Content -LiteralPath $yaml -Value $content -Encoding ASCII

$updaterPath = Join-Path $env:LOCALAPPDATA "lm-studio-updater"
Remove-Item -LiteralPath $updaterPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Disabled LM Studio updater config: $yaml"
Write-Host "Removed updater cache: $updaterPath"
