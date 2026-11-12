# Eye of GNOME Image Viewer (KEMI Linux)

Eye of GNOME Image Viewer — official Ubuntu 20.04 graphical image viewer for the GNOME desktop — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). Official Ubuntu package name is `eog`. Official GUI stanza Source field is absent and was not defaulted (`eog-dev` lists `Source: eog`, which was not copied onto kemi). Official Homepage `https://wiki.gnome.org/Apps/EyeOfGnome` is copied exactly. This is a real official lean GUI (focal-updates main, not a snap stub, not transitional, not -dev/docs-only). Official desktop Name=`Image Viewer` is kept (no official GenericName). Official appdata `<name>Eye of GNOME</name>` lives in the official GUI package and is packed. Mall app_name is **Eye of GNOME Image Viewer** (the usual English product title / official appdata name plus function; official desktop Name is the generic “Image Viewer”; the project/repo name `eog` is not used as mall app_name). Already-shipped Eye of MATE Image Viewer app456 is a distinct product, not occupancy and not a substitute.

No `eog-common` exists on Ubuntu 20.04, and there are no same-source exact-version hard Depends, so nothing is bundled. Official same-source `eog-dev` was inspected, not packaged. Official Recommends, Suggests, and Breaks are kept. kemi also Provides/Conflicts/Replaces official `eog`.

| field | value |
|---|---|
| app_id | **457** |
| package_name | `com.kemi.eog` |
| dpkg | `kemi-eog` |
| mall app_name | Eye of GNOME Image Viewer |
| official desktop Name | Image Viewer (kept) |
| official GenericName | none |
| official appdata `<name>` | Eye of GNOME (in official GUI; packed) |
| official binaries | `/usr/bin/eog`, private `libeog.so`, typelib `Eog-3.0.typelib`, plugins `libfullscreen.so` / `libreload.so` / `libstatusbar-date.so` |
| official package / source | `eog` / GUI Source field absent and not defaulted |
| mall version_name | `3.36.3-0ubuntu1kemi1` (`len()`==20; no Debian epoch; no tilde) / code **33630** |
| dpkg Version | `3.36.3-0ubuntu1kemi1` |
| bytes | 409636 |
| sha256 | `16bbbb915f904f7e92ee8be3d12c198065786f4554bde43e68547e838cc96b01` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794479101565_75230864_kemi-eog_3_36_3-0ubuntu1kemi1_arm64.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_3_36_3-0ubuntu1kemi1_arm64.deb`) |

Official pin prefers focal-updates when newer than Release: focal-updates main `eog_3.36.3-0ubuntu1_arm64.deb`, Version `3.36.3-0ubuntu1` (no epoch), 409600 B, sha256 `1e6c1dcf7f6778178bb9a1ec531be3ad1509f2100f913b883e65fbbbe1aaf60b`. Filename `pool/main/e/eog/eog_3.36.3-0ubuntu1_arm64.deb`. Not in focal-security index. Older focal Release main is `3.36.1-1` (408268 B, sha256 `f19d94ddb879ea7c297038631aab4205fdf53da406ba167af2733697679747df`), not used. Confirmed on ports.ubuntu.com and mirrors.aliyun.com/ubuntu-ports over https (16-index HTTP 200, live Packages via curl --max-time, not urllib).

Official ELF stays under /usr. `/opt/eog/eog` and `/usr/bin/kemi-eog` are symlinks only to `/usr/bin/eog`. Official relative Exec/TryExec rewritten absolute; `%U` kept. Official desktop Name kept. Official changelog is a regular file. 101 smoke is SKIP_TRANSPORT / not attempted. 合主线：gork.bot协助开发.
