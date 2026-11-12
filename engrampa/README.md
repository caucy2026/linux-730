# Engrampa Archive Manager (KEMI Linux)

Engrampa Archive Manager — official Ubuntu 20.04 graphical archive manager for the MATE desktop — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). Official Ubuntu package name is `engrampa`. Official GUI stanza Source field is absent and was not defaulted (sibling `engrampa-common` lists `Source: engrampa`, which was not copied onto kemi). Official Homepage `http://www.mate-desktop.org/` is copied exactly (http, not scheme-upgraded). This is a real official lean GUI. Official desktop Name=`Engrampa Archive Manager` and GenericName=`Archive Manager` are kept. Official appdata `<name>Engrampa Archive Manager</name>` lives in bundled `engrampa-common` and is packed. Mall app_name is **Engrampa Archive Manager** (the official desktop Name and official appdata title; more distinctive than the generic GenericName “Archive Manager”, and the project/repo name `engrampa` is not used as mall app_name). Not a transitional dummy, -dev, or docs package, and not an amd64-only package. Official same-source `engrampa-common` is an exact-version hard Depends (`= 1.24.0-2`) and is bundled. Official Recommends and Suggests are kept. Already-shipped file managers are distinct; official File Roller is still unshipped and is a distinct product, not occupancy and not a substitute.

| field | value |
|---|---|
| app_id | **452** |
| package_name | `com.kemi.engrampa` |
| dpkg | `kemi-engrampa` |
| mall app_name | Engrampa Archive Manager |
| official desktop Name | Engrampa Archive Manager (kept) |
| official GenericName | Archive Manager (kept) |
| official appdata `<name>` | Engrampa Archive Manager (in bundled common; packed) |
| official binaries | `/usr/bin/engrampa`, `/usr/lib/engrampa/engrampa-server`, caja extension `libcaja-engrampa.so` |
| official package / source | `engrampa` / GUI Source field absent and not defaulted |
| mall version_name | `1.24.0-2kemi1` (`len()`==13; no Debian epoch; no tilde) / code **1240** |
| dpkg Version | `1.24.0-2kemi1` |
| bytes | 1045352 |
| sha256 | `df0f07e354631974d8002b8024c596eee3c2e5bb01c4fa14acb0bfa7eaae07ef` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794475458322_24daf012_kemi-engrampa_1_24_0-2kemi1_arm64.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_1_24_0-2kemi1_arm64.deb`) |

Official pin (ports.ubuntu.com + mirrors.aliyun.com/ubuntu-ports https, SHA agree): focal universe Release `engrampa_1.24.0-2_arm64.deb`, Version `1.24.0-2` (no epoch), 199904 B, sha256 `74cca6ce770c8b0c8c51ea801410ce54369f06938ec7ae797e2a8bf865632371`. Filename `pool/universe/e/engrampa/engrampa_1.24.0-2_arm64.deb`. Bundled `engrampa-common` 1.24.0-2 all, 852320 B, sha256 `01b85c3b9d1e0844b2fc6b246d0f3942e8b785eef7d338657726cdede12f55c4`. Official GUI Source absent. Official Homepage `http://www.mate-desktop.org/`. Common’s alternatives Depends `dconf-gsettings-backend | gsettings-backend` merged into kemi Depends. Official Recommends `gvfs, unzip, xz-utils, zip` and official Suggests kept. Official Breaks/Replaces from GUI and bundled common kept; kemi also Provides/Conflicts/Replaces `engrampa` and `engrampa-common`.

Official `/usr/bin/engrampa` ELF stays at the official path; `/opt/engrampa/engrampa` and `/usr/bin/kemi-engrampa` are symlinks only. No invented `kemi-engrampa-server`. Official desktop relative Exec/TryExec rewritten absolute; `%U` kept. Official 133 `.mo`, schema, appdata, man, help, dbus service, caja extension descriptor, and official hicolor icons from bundled common packed at official paths. CREATE icon is a 128×128 RGBA evidence PNG from official packaged-tree scalable `engrampa.svg` (48×48 canvas, no viewBox; HTML wrapper); evidence is CREATE-only and is not packed; official SVG is packed once at the official path. Hooks: desktop-database, gtk-update-icon-cache, glib-compile-schemas (no ldconfig; no bundled shared lib from a Depends). leftover-x86 clear.

Probe: 3 unique aarch64 ELFs; requiredGlibc 2.17 (3 versioned, 0 null); requiredGlibcxx None (0 versioned, 3 null, not ranked as a max); configuredLimitsSatisfied true. 101 smoke: SKIP_TRANSPORT / not attempted. 合主线：gork.bot协助开发.

This recipe tarball is for the parent’s linux-730 PR. Do not open that PR from the executor. Do not start a second engrampa.
