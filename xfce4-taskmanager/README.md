# Xfce Task Manager (KEMI Linux)

Xfce Task Manager — official Ubuntu 20.04 graphical process manager for the Xfce desktop — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). Official Ubuntu package name is `xfce4-taskmanager`. Official GUI stanza Source field is absent and was not defaulted. Official Homepage `https://goodies.xfce.org/projects/applications/xfce4-taskmanager` is copied exactly. This is a real official lean GUI. Official desktop Name=`Task Manager` and GenericName=`Task Manager` are kept. Official package ships no appdata. Mall app_name is **Xfce Task Manager** (the usual upstream title; official desktop Name is the generic “Task Manager”, and the project/repo name `xfce4-taskmanager` is not used as mall app_name). Not a transitional dummy, -dev, or docs package, and not an amd64-only package. 16-index found only this official binary; official Depends are all different-source ranges, so nothing is bundled. Already-shipped GNOME System Monitor app360, MATE System Monitor app431, and LXTask app337 are distinct products, not occupancy.

| field | value |
|---|---|
| app_id | **451** |
| package_name | `com.kemi.xfce4-taskmanager` |
| dpkg | `kemi-xfce4-taskmanager` |
| mall app_name | Xfce Task Manager |
| official desktop Name | Task Manager (kept) |
| official GenericName | Task Manager (kept) |
| official appdata `<name>` | none in official package |
| official binaries | `/usr/bin/xfce4-taskmanager` |
| official package / source | `xfce4-taskmanager` / GUI Source field absent and not defaulted |
| mall version_name | `1.2.3-0ubuntu1kemi1` (`len()`==19; no Debian epoch; no tilde) / code **123** |
| dpkg Version | `1.2.3-0ubuntu1kemi1` |
| bytes | 100892 |
| sha256 | `c4b28c22e9aeb4387251f560c67483df0525e3c6ebfb5c646a1bbd2b0232d751` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794474738614_16790f23_kemi-xfce4-taskmanager_1_2_3-0ubuntu1kem.deb |
| CDN_TRUNCATED | **yes** (dots sanitized to underscores; exact stored URL ends `_1_2_3-0ubuntu1kem.deb`, cutting the `kemi1_arm64` tail; do not invent a complete URL) |

Official pin (ports.ubuntu.com + mirrors.aliyun.com/ubuntu-ports https, SHA agree): focal universe Release `xfce4-taskmanager_1.2.3-0ubuntu1_arm64.deb`, Version `1.2.3-0ubuntu1` (no epoch), 100088 B, sha256 `ccc5b4503c50155856357a0abe97741353b236d6c8645a4de49e362b93176496`. Filename `pool/universe/x/xfce4-taskmanager/xfce4-taskmanager_1.2.3-0ubuntu1_arm64.deb`. Official GUI Source absent. Official Homepage `https://goodies.xfce.org/projects/applications/xfce4-taskmanager`. Not bundled. Official Recommends/Suggests/Conflicts/Breaks/Replaces/Provides: none. kemi Provides `xfce4-taskmanager (= 1.2.3-0ubuntu1)` and Conflicts/Replaces the original name.

Official `/usr/bin/xfce4-taskmanager` ELF stays at the official path; `/opt/xfce4-taskmanager/xfce4-taskmanager` and `/usr/bin/kemi-xfce4-taskmanager` are symlinks only. Official desktop relative Exec rewritten absolute; TryExec added. Official 55 `.mo`, man page, changelog, copyright, and official hicolor action icons (`xc_crosshair`) packed at official paths. CREATE icon is a 128×128 RGBA evidence PNG from official U20 humanity-icon-theme 0.6.15 `apps/48/utilities-system-monitor.svg` (theme has 24/32/48 SVG only; 48 is the largest official available); evidence is CREATE-only and is not packed; the theme is not bundled. Official action artwork is not used as the mall icon. Hooks: desktop-database and gtk-update-icon-cache (official hicolor packed). No schemas and no bundled lib, so no glib-compile-schemas and no ldconfig. leftover-x86 clear.

Probe: 1 unique aarch64 ELF; requiredGlibc 2.17 (1 versioned, 0 null); requiredGlibcxx None (0 versioned, 1 null, not ranked as a max); configuredLimitsSatisfied true. 101 smoke: SKIP_TRANSPORT / not attempted. 合主线：gork.bot协助开发.

This recipe tarball is for the parent’s linux-730 PR. Do not open that PR from the executor. Do not start a second xfce4-taskmanager.
