param(
    [Parameter(Mandatory = $true, Position = 0)][string]$UpstreamUrl,
    [Parameter(Mandatory = $true, Position = 1)][string]$ManifestPath
)
$ErrorActionPreference = 'Stop'
$manifest = Invoke-RestMethod -Uri $UpstreamUrl
if (-not $manifest.version -or -not $manifest.architecture.'64bit'.url -or -not $manifest.architecture.'64bit'.hash) {
    throw 'Upstream Feishu manifest is missing its version, download URL or hash.'
}
# Extras-CN owns release metadata. Excavator must not update this app separately.
$manifest.PSObject.Properties.Remove('checkver')
$manifest.PSObject.Properties.Remove('autoupdate')
$hook = @($manifest.post_install | Where-Object { $null -ne $_ })
$hook += '& {'
$hook += [IO.File]::ReadAllLines((Join-Path $PSScriptRoot 'patch-hotkey.ps1'))
$hook += '} "$dir\app\webcontent\js-worker\worker_temperate.js"'
$manifest | Add-Member -MemberType NoteProperty -Name post_install -Value $hook -Force
if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = Convert-Path (scoop prefix scoop) }
. "$env:SCOOP_HOME/lib/json.ps1"
$content = (($manifest | ConvertToPrettyJson) -replace "`t", '    ') + [Environment]::NewLine
if ((Test-Path -LiteralPath $ManifestPath) -and [IO.File]::ReadAllText($ManifestPath) -eq $content) { return }
[IO.File]::WriteAllText([IO.Path]::GetFullPath($ManifestPath), $content, (New-Object Text.UTF8Encoding $false))
Write-Host "Synced Feishu $($manifest.version) from Extras-CN with the local hotkey patch."
