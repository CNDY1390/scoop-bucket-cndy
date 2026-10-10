param([Parameter(Mandatory = $true, Position = 0)][string]$Path)
$ErrorActionPreference = 'Stop'
$Path = (Resolve-Path -LiteralPath $Path).Path
$source = [IO.File]::ReadAllText($Path)
$marker = '/* local-feishu-recording-hotkey-v2 */'
$marked = [regex]::Matches($source, [regex]::Escape($marker)).Count
if ($marked -eq 1) { Write-Host '录屏快捷键补丁已存在。'; return }
if ($marked -gt 1) { throw '发现重复补丁标记，停止修改。' }
$sites = [regex]::Matches($source, '"lark\.shortcut\.screen_record":\{key:([A-Za-z_$][\w$]*)\.screenRecord,local:!0,global:!0\}')
if ($sites.Count -ne 1) { throw "预期找到一处原始代码，实际找到 $($sites.Count) 处。停止修改；请使用未打补丁的文件。" }
$site = $sites[0]
$binding = $site.Groups[1].Value + '.screenRecord'
# 空绑定必须同时关闭本地和全局快捷键；Alt+Shift+R 按空绑定处理。
$replacement = @"
"lark.shortcut.screen_record": $marker
    !$binding || /^(?:Alt\+Shift|Shift\+Alt)\+R$/i.test($binding)
        ? {key: "", local: false, global: false}
        : {key: $binding, local: true, global: true}
"@
$backup = Join-Path ([IO.Path]::GetTempPath()) ('Codex-recovery\feishu-hotkey-' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($backup) | Out-Null
Copy-Item -LiteralPath $Path -Destination $backup
[IO.File]::WriteAllText($Path, $source.Replace($site.Value, $replacement), (New-Object Text.UTF8Encoding $false))
Write-Host "已修正录屏快捷键同步，重启飞书后加载。原文件备份：$backup"
Write-Host '此补丁尚未验证企业切换时的旧快捷键注销行为。'
