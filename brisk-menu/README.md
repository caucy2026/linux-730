# Brisk Menu (KEMI Linux)

Brisk Menu — Solus Project's modern MATE panel menu applet — packaged for KEMI mall (Architecture: arm64, Ubuntu 20.04 / 101). Official Ubuntu binary package name is `mate-applet-brisk-menu`. Official GUI Source field `brisk-menu` is copied exactly. Official Homepage `http://www.mate-desktop.org/` is copied exactly (http; the scheme is not upgraded). This is a real official lean MATE panel-applet GUI. There is no official `/usr/share/applications/*.desktop` and no official appdata; none was invented. Official applet Name=`Brisk Menu` and Factory Name=`Brisk Menu Factory` are kept in the official `.mate-panel-applet` file. Official package has no `/usr/bin` command; `/usr/bin/kemi-mate-applet-brisk-menu` and `/opt/brisk-menu` were not invented. Official Location and D-Bus Exec are already absolute (including the official double slash `brisk-menu//brisk-menu`) and are kept. Mall app_name is **Brisk Menu** (the usual upstream title, matching the official applet Name and official Description “Brisk Menu is a modern desktop menu…”). Not a transitional dummy, -dev, or docs package, and not an amd64-only package. No exact-version same-source hard Depends existed to bundle (the 16-index pin found no same-source siblings). Official Depends stay Depends. Official Recommends/Suggests: none. Official Conflicts/Breaks/Replaces/Provides: none in the official stanza; the kemi package Conflicts/Replaces/Provides official `mate-applet-brisk-menu`.

| field | value |
|---|---|
| app_id | **445** |
| package_name | `com.kemi.mate-applet-brisk-menu` |
| dpkg | `kemi-mate-applet-brisk-menu` |
| mall app_name | Brisk Menu |
| official applications desktop Name | (none; official package ships no `/usr/share/applications/*.desktop`; none invented) |
| official applet Name | Brisk Menu (kept in `com.solus_project.brisk.BriskMenu.mate-panel-applet`) |
| official GenericName | (none) |
| official appdata `<name>` | (none; official package ships no appdata) |
| official command | (none in `/usr/bin`; official ELF is `/usr/lib/aarch64-linux-gnu/brisk-menu/brisk-menu`; no kemi/`/opt` launcher invented) |
| official package / source | `mate-applet-brisk-menu` / `Source: brisk-menu` copied exactly |
| mall version_name | `0.6.0-1ubuntu1kemi1` (`len()`==19; no Debian epoch; no tilde; no padding needed) / code **60** |
| dpkg Version | `0.6.0-1ubuntu1kemi1` |
| bytes | 59700 |
| sha256 | `4ed2cfa6d7b0f388b519186a521ff306dc1ebd99c8c28f47eb7bf41e636b9db3` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794443964956_42656a8e_kemi-mate-applet-brisk-menu_0_6_0-1ubunt.deb |
| CDN_TRUNCATED | **yes** (exact stored URL ends `_0_6_0-1ubunt.deb`; the tail `u1kemi1_arm64.deb` was cut; do not invent a complete URL) |

Official pin (re-confirmed newest pocket on ports https + Aliyun https, 16-index: 2 mirrors × 4 pockets × 2 components binary-arm64): focal universe Release only `mate-applet-brisk-menu_0.6.0-1ubuntu1_arm64.deb`, Version `0.6.0-1ubuntu1` (no epoch), Size 59392, sha256 `e34ea29334b583041687396f0cc82688095ba038830b40d31e902e44f600d3f7`. Not in focal-updates / focal-security / focal-backports.

Probe PASS: 1 unique aarch64 ELF, requiredGlibc 2.17 (within the 101 ceiling of 2.31), no GLIBCXX. Official files stay under `/usr`. Official 43 `.mo`, official schema, and official hicolor action SVG packed; none invented. Official package ships no app icon (theme name `start-here` on the applet). Official action icon packed at the official path, not used as the mall icon. 128 evidence PNG is from official U20 humanity-icon-theme 0.6.15 `places/64/start-here.svg` (largest official available; no 128 or scalable start-here in humanity), CREATE-only, theme not bundled. Official changelog and copyright are real files and are kept.

101 smoke is SKIP_TRANSPORT (do not connect, do not touch vibekits). linux-730 recipe PR is left to the parent.

合主线：gork.bot协助开发
