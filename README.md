# scoop-bucket-cndy

Personal [Scoop](https://scoop.sh) bucket for Windows app manifests that are not covered well by the default buckets.

## Install

```pwsh
scoop bucket add scoop-bucket-cndy https://github.com/CNDY1390/scoop-bucket-cndy
scoop install scoop-bucket-cndy/<manifest>
```

## Manifests

| Manifest | App | Notes |
| --- | --- | --- |
| `linear` | Linear Desktop | Uses the official Windows download endpoint. The built-in Electron updater is disabled by editing `resources\app-update.yml`, matching the pattern used by Scoop extras packages such as Notion and Antigravity. |
| `lm-studio` | LM Studio | Uses the current fixed Windows x64 installer URL. The built-in Electron updater is disabled by editing `resources\app-update.yml` and clearing the updater cache. |
| `pencil` | Pencil.dev | AI-powered infinite canvas design tool. |

## Maintenance Scripts

The manifests disable built-in updaters during install/update. For already-installed copies, run:

```pwsh
powershell -ExecutionPolicy Bypass -File .\scripts\linear\disable-linear-updater.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\lm-studio\disable-lm-studio-updater.ps1
```

Each script can also take an explicit install directory as its first argument.

## How do I contribute new manifests?

Use the official Scoop manifest style as the baseline for this bucket. Before adding or changing a manifest, check the
[Contributing Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md), the
[App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests) wiki page, and similar manifests in the
official `main`, `extras`, or `versions` buckets.

Prefer the patterns already used by official Scoop packages: stable download URLs, reproducible hashes, `checkver` and
`autoupdate` where possible, and narrowly scoped install scripts instead of app-specific workarounds unless the upstream
installer requires them.
