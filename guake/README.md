# Guake (KEMI Linux)

Guake — drop-down terminal for GNOME — packaged for KEMI mall (Architecture: all, Ubuntu 20.04 / 101). Official Ubuntu package name is `guake`. Official GUI Source field is **absent** and is not defaulted. Official Homepage `http://guake-project.org` is copied exactly (http; the scheme is not upgraded; no trailing slash invented). This is a real official lean Python/GTK drop-down terminal GUI. Official desktop Name=`Guake Terminal` and prefs Name=`Guake Preferences` are kept in the official files. Official appdata `<name>Guake</name>` is the more distinctive usual title and is used as mall app_name **Guake**. Official applications desktops are symlinks into official templates; that official symlink structure is kept and the templates were rewritten. Official relative Exec/TryExec rewritten absolute (arguments kept). Official `/usr/bin/guake` exists; `/opt/guake/guake` and `/usr/bin/kemi-guake` are symlinks only. Official `guake-toggle` stays at the official path; `kemi-guake-toggle` was not invented. Official autostart `NoDisplay=false` is kept. Not a transitional dummy, -dev, or docs package, and not an amd64-only package. No exact-version same-source hard Depends existed to bundle. Official Depends stay Depends. Official Suggests `numix-gtk-theme` stay Suggests (theme not bundled). Official Recommends: none. Official Conflicts/Breaks/Replaces/Provides: none in the official stanza; the kemi package Conflicts/Replaces/Provides official `guake`. Different-product `guake-indicator` was inspected and not packaged.

| field | value |
|---|---|
| app_id | **447** |
| package_name | `com.kemi.guake` |
| dpkg | `kemi-guake` |
| mall app_name | Guake |
| official desktop Name | Guake Terminal (kept); prefs: Guake Preferences (kept) |
| official GenericName | (none) |
| official appdata `<name>` | Guake |
| official command | `/usr/bin/guake` (Python; official `guake-toggle` also packed at the official path) |
| official package / source | `guake` / official Source field **absent**, not defaulted |
| mall version_name | `3.6.3-2kemi1` (`len()`==12; no Debian epoch; no tilde; no padding needed) / code **363** |
| dpkg Version | `3.6.3-2kemi1` |
| bytes | 783948 |
| sha256 | `99c0ee9f2ce110f448bd328e9a4a533d33d55f52517406c53c8ceb818729feb6` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794445051193_d555d5a4_kemi-guake_3_6_3-2kemi1_all.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_3_6_3-2kemi1_all.deb`) |

Official pin (re-confirmed newest pocket on ports https + Aliyun https, 16-index: 2 mirrors × 4 pockets × 2 components binary-arm64): focal universe Release only `guake_3.6.3-2_all.deb`, Version `3.6.3-2` (no epoch), Size 783620, sha256 `d3f1e8217511d812a762d23a7a9ec80339066084560c0f927b6acaacff7e7f3c`. Not in focal-updates / focal-security / focal-backports.

Vacuous 0-ELF probe PASS (Architecture: all Python/GTK GUI). Official files stay under `/usr`. Official 25 `.mo`, official schema, official man, official pixmaps (including official 128 PNG) packed; none invented. Official 128 PNG is packed at the official path and used as CREATE `--icon`. Official changelog, copyright, and man are real files and are kept.

101 smoke is SKIP_TRANSPORT (do not connect, do not touch vibekits). linux-730 recipe PR is left to the parent.

合主线：gork.bot协助开发
