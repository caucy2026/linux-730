# Variety (KEMI Linux)

Variety — wallpaper changer, downloader and manager — packaged for KEMI mall (Architecture: all, Ubuntu 20.04 / 101). Official Ubuntu package name is `variety`. Official GUI Source field is **absent** and is not defaulted. Official Homepage `http://peterlevi.com/variety/` is copied exactly (http; the scheme is not upgraded). This is a real official lean Python/GTK wallpaper-changer GUI (not an image viewer). Official desktop Name=`Variety` is kept. Official appdata `<name>Variety</name>` matches that usual title. Official package has no GenericName and no NoDisplay; none was invented. Official relative Exec lines were rewritten absolute and TryExec was added (arguments kept). Official `/usr/bin/variety` exists; `/opt/variety/variety` and `/usr/bin/kemi-variety` are symlinks only. Mall app_name is **Variety** (the usual upstream title, matching the official desktop Name and official appdata `<name>`). Not a transitional dummy, -dev, or docs package, and not an amd64-only package. No exact-version same-source hard Depends existed to bundle (the 16-index pin found no same-source siblings). Official Depends stay Depends. Official Recommends stay Recommends. Official Suggests stay Suggests. Official Conflicts/Breaks/Replaces/Provides: none in the official stanza; the kemi package Conflicts/Replaces/Provides official `variety`.

| field | value |
|---|---|
| app_id | **446** |
| package_name | `com.kemi.variety` |
| dpkg | `kemi-variety` |
| mall app_name | Variety |
| official desktop Name | Variety (kept in `variety.desktop`) |
| official GenericName | (none) |
| official appdata `<name>` | Variety |
| official command | `/usr/bin/variety` (Python shebang) |
| official package / source | `variety` / official Source field **absent**, not defaulted |
| mall version_name | `0.8.3-1kemi1` (`len()`==12; no Debian epoch; no tilde; no padding needed) / code **83** |
| dpkg Version | `0.8.3-1kemi1` |
| bytes | 525240 |
| sha256 | `a911f1efd7adcce176f795c1d9706b0f487d36e70da56b5db693b17f79a7aa51` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794444524703_28161d1c_kemi-variety_0_8_3-1kemi1_all.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_0_8_3-1kemi1_all.deb`) |

Official pin (re-confirmed newest pocket on ports https + Aliyun https, 16-index: 2 mirrors × 4 pockets × 2 components binary-arm64): focal universe Release only `variety_0.8.3-1_all.deb`, Version `0.8.3-1` (no epoch), Size 525192, sha256 `9b011392927f31bbffa9f6f5ee0cc961a222a17c9c8f98c3f2d008bd28e1cc02`. Not in focal-updates / focal-security / focal-backports.

Vacuous 0-ELF probe PASS (Architecture: all Python/GTK GUI). Official files stay under `/usr`. Official 13 `.mo`, official hicolor app SVG and 22x22 indicator PNGs, official man, official appdata packed; none invented. 128 evidence PNG is from official `usr/share/icons/hicolor/scalable/apps/variety.svg`, CREATE-only. Official changelog, copyright, and man are real files and are kept.

101 smoke is SKIP_TRANSPORT (do not connect, do not touch vibekits). linux-730 recipe PR is left to the parent.

合主线：gork.bot协助开发
