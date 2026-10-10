param([Parameter(Mandatory = $true, Position = 0)][string]$Path)
$ErrorActionPreference = 'Stop'
$Path = (Resolve-Path -LiteralPath $Path).Path
$source = [IO.File]::ReadAllText($Path)
$marker = '/* local-feishu-alt-shift-r */'
$marked = [regex]::Matches($source, [regex]::Escape($marker)).Count
if ($marked -eq 1) { Write-Host 'Feishu hotkey patch already present.'; return }
if ($marked -gt 1) { throw 'Duplicate Feishu patch markers; no changes made.' }
$sites = [regex]::Matches($source, '"lark\.shortcut\.screen_record":\{key:([A-Za-z_$][\w$]*)\.screenRecord,local:!0,global:!0\}')
if ($sites.Count -ne 1) { throw "Feishu hotkey code changed: expected one site, found $($sites.Count). No changes made." }
$site = $sites[0]
$binding = $site.Value.Substring($site.Value.IndexOf(':') + 1)
$replacement = '"lark.shortcut.screen_record":' + $marker + '/^(?:Alt\+Shift|Shift\+Alt)\+R$/i.test(' + $site.Groups[1].Value + '.screenRecord)?{key:"",local:!1,global:!1}:' + $binding
$patched = $source.Substring(0, $site.Index) + $replacement + $source.Substring($site.Index + $site.Length)
$backup = Join-Path ([IO.Path]::GetTempPath()) ('Codex-recovery\feishu-hotkey-' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($backup) | Out-Null
Copy-Item -LiteralPath $Path -Destination $backup
[IO.File]::WriteAllText($Path, $patched, (New-Object Text.UTF8Encoding $false))
Write-Host "Patched Feishu recording-hotkey sync. Backup: $backup"
Write-Host 'Restart Feishu later to load the patch. Other registration paths are not covered.'
