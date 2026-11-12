# Caja Admin (KEMI Linux)

Caja Admin — add administrative actions to Caja's right-click menu — packaged for KEMI mall (Architecture: all, Ubuntu 20.04 / 101). Official Ubuntu package name is `caja-admin`. Official GUI Source field is **absent** and is not defaulted. Official Homepage `https://github.com/infirit/caja-admin/` is copied exactly (trailing slash kept). This is a real official lean Python Caja-extension GUI. There is no official `/usr/share/applications/*.desktop` and no official appdata; none was invented. Official package has no `/usr/bin` command; `/usr/bin/kemi-caja-admin` and `/opt/caja-admin` were not invented. Mall app_name is **Caja Admin** (the usual upstream title from official Description “Caja Admin is a simple Python extension…” and official polkit vendor `Caja Admin`). Not a transitional dummy, -dev, or docs package, and not an amd64-only package. No exact-version same-source hard Depends existed to bundle. Official different-source range Depends `python3-caja (>= 1.23.0)` (source `python-caja`) stays Depends. Official Depends `python3-gi, gir1.2-gtk-3.0, caja, policykit-1` stay Depends. Official Recommends `pluma, mate-terminal` stay Recommends. Official Suggests: none. Official Conflicts/Breaks/Replaces/Provides: none in the official stanza; the kemi package Conflicts/Replaces/Provides official `caja-admin`.

| field | value |
|---|---|
| app_id | **444** |
| package_name | `com.kemi.caja-admin` |
| dpkg | `kemi-caja-admin` |
| mall app_name | Caja Admin |
| official applications desktop Name | (none; official package ships no `/usr/share/applications/*.desktop`; none invented) |
| official GenericName | (none) |
| official appdata `<name>` | (none; official package ships no appdata) |
| official command | (none; official package ships no `/usr/bin` command; no kemi/`/opt` launcher invented) |
| official package / source | `caja-admin` / official Source field **absent**, not defaulted |
| mall version_name | `0.0.1-3build1kemi1` (`len()`==18; no Debian epoch; no tilde; no padding needed) / code **1** |
| dpkg Version | `0.0.1-3build1kemi1` |
| bytes | 12376 |
| sha256 | `0b8ed6c5dbe2414e86d6d144858b25f33eb73066c136710adc4b6c4151bc8323` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794443492513_4698c221_kemi-caja-admin_0_0_1-3build1kemi1_all.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_0_0_1-3build1kemi1_all.deb`) |

Official pin (re-confirmed newest pocket on ports https + Aliyun https, 16-index: 2 mirrors × 4 pockets × 2 components binary-arm64): focal universe Release only `caja-admin_0.0.1-3build1_all.deb`, Version `0.0.1-3build1` (no epoch), Size 12356, sha256 `ae5232ed4da0a37da9ee93cce25fc551c931e63efb9abbe5fa235297f093b083`. Not in focal-updates / focal-security / focal-backports.

Vacuous 0-ELF probe PASS (Architecture: all Python Caja extension). Official files stay under `/usr`. Official 11 `.mo` and the official polkit policy packed; none invented. Official package ships no app icon; official polkit action `icon_name` values are `system-file-manager`, `accessories-text-editor`, and `utilities-terminal`. 128 evidence PNG is from official U20 humanity-icon-theme 0.6.15 `apps/128/system-file-manager.svg` (the first/primary official policy icon_name), CREATE-only, theme not bundled. Official changelog and copyright are real files and are kept.

101 smoke is SKIP_TRANSPORT (do not connect, do not touch vibekits). linux-730 recipe PR is left to the parent.

合主线：gork.bot协助开发
