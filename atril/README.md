# Atril Document Viewer (KEMI Linux)

Atril Document Viewer — official Ubuntu 20.04 graphical document viewer for the MATE desktop — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). Official Ubuntu package name is `atril`. Official GUI stanza Source field is absent and was not defaulted (sibling `atril-common`, `libatrildocument3`, and `libatrilview3` list `Source: atril`, which was not copied onto kemi). Official Homepage `https://mate-desktop.org/` is copied exactly (https, no trailing path invented). This is a real official lean GUI. Official desktop Name=`Atril Document Viewer` and GenericName=`Document Viewer` are kept. Official appdata `<name>Atril Document Viewer</name>` lives in unbundled `atril-common` and is not packed. Mall app_name is **Atril Document Viewer** (the official desktop Name and official appdata title; more distinctive than the generic GenericName “Document Viewer”, and the project/repo name `atril` is not used as mall app_name). Not a transitional dummy, -dev, or docs package, and not an amd64-only package. Official same-source `libatrildocument3` and `libatrilview3` are exact-version hard Depends (`= 1.24.0-1ubuntu0.2`) and are bundled. Official same-source range Depends `atril-common (>= 1.24.0-1ubuntu0.2)` stays Depends and is not bundled. Official Recommends and Suggests are kept. Already-shipped Evince is still unshipped and is a distinct product, not occupancy and not a substitute.

| field | value |
|---|---|
| app_id | **453** |
| package_name | `com.kemi.atril` |
| dpkg | `kemi-atril` |
| mall app_name | Atril Document Viewer |
| official desktop Name | Atril Document Viewer (kept) |
| official GenericName | Document Viewer (kept) |
| official appdata `<name>` | Atril Document Viewer (in unbundled common; not packed) |
| official binaries | `/usr/bin/atril`, `/usr/bin/atril-previewer`, `/usr/bin/atril-thumbnailer` (kept; no invented kemi-atril-previewer / kemi-atril-thumbnailer / kemi-atrild) |
| official package / source | `atril` / GUI Source field absent and not defaulted |
| mall version_name | `1.24.0-1ubuntu0.2kemi1` (`len()`==22; no Debian epoch; no padding) / code **1240** (coincidental reuse with mate-calc/engrampa 1.24.0 allowed) |
| dpkg Version | `1.24.0-1ubuntu0.2kemi1` |
| bytes | 402468 |
| sha256 | `fdbae5444e3fba14b245bd431cd47da168e55906ac924d645c82e1333d6563da` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794476303752_9a078ca6_kemi-atril_1_24_0-1ubuntu0_2kemi1_arm64.deb |
| CDN_TRUNCATED | **no** (dots sanitized, including `0.2`→`0_2`; exact stored URL ends `_1_24_0-1ubuntu0_2kemi1_arm64.deb`) |

Official pin (ports.ubuntu.com + mirrors.aliyun.com/ubuntu-ports https, SHA agree; 16-index HTTP 200, FAILS 0; prefer updates when newer): focal-updates universe (same SHA in focal-security) `atril_1.24.0-1ubuntu0.2_arm64.deb`, Version `1.24.0-1ubuntu0.2` (no epoch), 163920 B, sha256 `b51a37b4ee92c10269b4f07ba46dc971e73bec7d2dcd05b0843189ce6d4bc258`. Filename `pool/universe/a/atril/atril_1.24.0-1ubuntu0.2_arm64.deb`. Official Debian changelog `atril (1.24.0-1ubuntu0.2) focal-security` uploaded Thu, 13 Feb 2025 13:46:25 +0000 (2025-02-13 21:46:25 Asia/Shanghai). Bundled `libatrildocument3` 1.24.0-1ubuntu0.2 arm64, 165728 B, sha256 `5c4efb6d21e572265b2e208eab9db1f0b7e77248d4453ef637bce1cfd8c1d68b`, and `libatrilview3` 1.24.0-1ubuntu0.2 arm64, 103748 B, sha256 `928a834a7571e23c206e208de26685e6d832807721e949dda11fd2fb30f45114`. Official GUI Source absent. Official Homepage `https://mate-desktop.org/`. Bundled-lib different-source Depends merged; libc6 tightened 2.17→2.29; libcairo2 tightened to ≥1.14.0. Official Recommends `default-dbus-session-bus | dbus-session-bus, gvfs` and official Suggests `caja, poppler-data, unrar` kept. Official Breaks/Replaces/Provides kept; kemi also Provides/Conflicts/Replaces `atril`, `libatrildocument3`, and `libatrilview3`.

Official `/usr/bin/atril`, `atril-previewer`, and `atril-thumbnailer` stay at official paths; `/opt/atril/*` and `/usr/bin/kemi-atril` are symlinks only. No invented `kemi-atril-previewer`, `kemi-atril-thumbnailer`, or `kemi-atrild`. Official desktop relative Exec/TryExec rewritten absolute; `%U` kept. Official GUI schema and man packed. Official 134 `.mo`, appdata, help, and hicolor `apps/atril` icons live only in unbundled common and were not packed. Official Icon=`atril`; official U20 humanity 0.6.15 has no atril app icon. CREATE icon is a 128×128 RGBA evidence PNG from official U20 `atril-common` scalable `atril.svg` (20572 B, sha256 `4579e8f7b09f4e1583359c9a66eb189b7a8316f4191d4b3c02f0247d5dd0d3a5`, 48×48, no viewBox; HTML wrapper); evidence is CREATE-only and is not packed; common and theme are not bundled. Official GUI changelog is a dangling symlink into bundled `libatrildocument3`; official symlink is kept (resolves after bundling) and `cp -L` into the kemi doc dir. Bundled lib changelog real file 1800 B, sha256 `58684e5cc9f90d2b22940f0365b7307741462abb7ac199c768dfe21a4eea4b01`; copyright 27529 B, sha256 `3e5db2adc229dbd3a31644e5345ea69c79974a6ebe4d0704ee45502a9fba4344`. Hooks: desktop-database, glib-compile-schemas, ldconfig (no icon-cache, because no packed hicolor). leftover-x86 clear.

Probe: 16 unique aarch64 ELFs; requiredGlibc 2.29 (16 versioned, 0 null; values 2.17 and 2.29); requiredGlibcxx None (0 versioned, 16 null, not ranked as a max); configuredLimitsSatisfied true. 101 smoke: SKIP_TRANSPORT / not attempted. 合主线：gork.bot协助开发.

This recipe tarball is for the parent’s linux-730 PR. Do not open that PR from the executor. Do not start a second atril.
