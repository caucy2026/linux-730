# File Roller (KEMI Linux)

File Roller — official Ubuntu 20.04 graphical archive manager for the GNOME desktop — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). Official Ubuntu package name is `file-roller`. Official GUI stanza Source field is absent and was not defaulted. Official Homepage `https://wiki.gnome.org/Apps/FileRoller` is copied exactly. This is a real official lean GUI (focal-updates/security main, not a snap stub, not transitional, not -dev/docs-only). Official desktop Name=`Archive Manager` is kept (no official GenericName). Official appdata `<name>File Roller</name>` lives in the official GUI package and is packed. Mall app_name is **File Roller** (the usual English product title / official appdata name; official desktop Name is the generic “Archive Manager”; the project/repo name `file-roller` is not used as mall app_name). Already-shipped Engrampa Archive Manager app452 is a distinct product, not occupancy and not a substitute.

No same-source exact-version hard Depends exist, so nothing is bundled. Official Recommends and Suggests are kept. kemi also Provides/Conflicts/Replaces official `file-roller`.

| field | value |
|---|---|
| app_id | **455** |
| package_name | `com.kemi.file-roller` |
| dpkg | `kemi-file-roller` |
| mall app_name | File Roller |
| official desktop Name | Archive Manager (kept) |
| official GenericName | none |
| official appdata `<name>` | File Roller (in official GUI; packed) |
| official binaries | `/usr/bin/file-roller`, `/usr/libexec/file-roller/isoinfo.sh`, `/usr/libexec/file-roller/rpm2cpio`, nautilus extension `libnautilus-fileroller.so` |
| official package / source | `file-roller` / GUI Source field absent and not defaulted |
| mall version_name | `3.36.3-0ubuntu1.1kemi1` (`len()`==22; no Debian epoch; no tilde) / code **33631** |
| dpkg Version | `3.36.3-0ubuntu1.1kemi1` |
| bytes | 234712 |
| sha256 | `0d70a43c68f4b256b081b117ec93201fc41c106923206166c31011d962250ee5` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794478041938_732caaf9_kemi-file-roller_3_36_3-0ubuntu1_1kemi1_.deb |
| CDN_TRUNCATED | **yes** (dots sanitized to underscores; exact stored URL ends `_3_36_3-0ubuntu1_1kemi1_.deb`; `arm64` tail cut; do not invent a complete URL) |

Official pin prefers focal-updates when newer than Release: focal-updates main and focal-security main (same SHA) `file-roller_3.36.3-0ubuntu1.1_arm64.deb`, Version `3.36.3-0ubuntu1.1` (no epoch), 234404 B, sha256 `b02ac6f1e8a56abd672bd97aac7065a8ebd152e516d66e6f96d8ed27737da9c6`. Filename `pool/main/f/file-roller/file-roller_3.36.3-0ubuntu1.1_arm64.deb`. Confirmed on ports.ubuntu.com and mirrors.aliyun.com/ubuntu-ports over https (16-index HTTP 200, live Packages via curl --max-time, not urllib). Older focal Release main is `3.36.1-1` (233464 B, sha256 `856e46dba013d27c914d234e00e8bf9ddf8f5ddb26e4a2650ecc1fbc3341ea0f`), not used.

Official ELF stays under /usr. `/opt/file-roller/file-roller` and `/usr/bin/kemi-file-roller` are symlinks only to `/usr/bin/file-roller`. Official libexec helpers `isoinfo.sh` and `rpm2cpio` stay at official paths; no invented `kemi-rpm2cpio` or `kemi-isoinfo.sh`. Official relative Exec/TryExec rewritten absolute; `%U` kept. Official desktop Name kept. 101 smoke is SKIP_TRANSPORT / not attempted. 合主线：gork.bot协助开发.
