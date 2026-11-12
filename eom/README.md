# Eye of MATE Image Viewer (KEMI Linux)

Eye of MATE Image Viewer — official Ubuntu 20.04 graphical image viewer for the MATE desktop — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). Official Ubuntu package name is `eom`. Official GUI stanza Source field is absent and was not defaulted (`eom-common` lists `Source: eom`, which was not copied onto kemi). Official Homepage `http://www.mate-desktop.org/` is copied exactly (http, no scheme upgrade). This is a real official lean GUI (focal universe, not a snap stub, not transitional, not -dev/docs-only). Official desktop Name=`Eye of MATE Image Viewer` is kept (no official GenericName). Official appdata `<name>Eye of MATE</name>` lives in bundled `eom-common` and is packed. Mall app_name is **Eye of MATE Image Viewer** (the official desktop Name / usual English product title; the project/repo name `eom` is not used as mall app_name). Already-shipped Atril Document Viewer app453 and Evince Document Viewer app454 are distinct products, not occupancy and not substitutes.

Official same-source `eom-common` is an exact-version hard Depends (`= 1.24.0-1`, Architecture: all) and is bundled. Official unversioned `gir1.2-eom-1.0` is a gir Depends, inspected not packaged, and stays Depends. `eom-dev` and transitional `gir1.2-eom` were inspected, not packaged. Official Breaks/Replaces are kept (and common Breaks merged). kemi also Provides/Conflicts/Replaces official `eom` and bundled `eom-common`.

| field | value |
|---|---|
| app_id | **456** |
| package_name | `com.kemi.eom` |
| dpkg | `kemi-eom` |
| mall app_name | Eye of MATE Image Viewer |
| official desktop Name | Eye of MATE Image Viewer (kept) |
| official GenericName | none |
| official appdata `<name>` | Eye of MATE (in bundled eom-common; packed) |
| official binaries | `/usr/bin/eom`, plugins `libfullscreen.so` / `libreload.so` / `libstatusbar-date.so` |
| official package / source | `eom` / GUI Source field absent and not defaulted |
| mall version_name | `1.24.0-1kemi1` (`len()`==13; no Debian epoch; no tilde) / code **1240** |
| dpkg Version | `1.24.0-1kemi1` |
| bytes | 1646224 |
| sha256 | `d9de6d59c59cf2297598f3da92d6c8227f4aca11c3153668d2423855b9382b56` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794478588687_9d38a57c_kemi-eom_1_24_0-1kemi1_arm64.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_1_24_0-1kemi1_arm64.deb`) |

Official pin is focal universe (not in updates/security): `eom_1.24.0-1_arm64.deb`, Version `1.24.0-1` (no epoch), 179024 B, sha256 `2e2b32acb8f35cf69eff62faeab6dd1db1da735249ea46fc7efea7dac20c0374`. Filename `pool/universe/e/eom/eom_1.24.0-1_arm64.deb`. Confirmed on ports.ubuntu.com and mirrors.aliyun.com/ubuntu-ports over https (16-index HTTP 200, live Packages via curl --max-time, not urllib).

Official ELF stays under /usr. `/opt/eom/eom` and `/usr/bin/kemi-eom` are symlinks only to `/usr/bin/eom`. Official relative Exec/TryExec rewritten absolute; `%U` kept. Official desktop Name kept. Official GUI changelog dangling into unbundled gir was not packed; official changelog content was `cp -L` into the kemi doc dir only. 101 smoke is SKIP_TRANSPORT / not attempted. 合主线：gork.bot协助开发.
