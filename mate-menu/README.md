# MATE Menu (KEMI Linux)

MATE Menu — advanced MATE menu (official panel applet) — packaged for KEMI mall (Architecture: all, Ubuntu 20.04 / 101). Official Ubuntu package name is `mate-menu`. Official GUI Source field is **absent** and is not defaulted (do not copy Source: mate-menus from different-source library siblings). Official Homepage `https://github.com/ubuntu-mate/mate-menu/` is copied exactly (trailing slash kept). This is a real official lean Python/GTK panel-applet GUI. There is no official `/usr/share/applications/*.desktop` and no official appdata; none was invented. Official applet Name=`Advanced MATE Menu` is kept in the official `.mate-panel-applet` file and is not the mall app_name. Mall app_name is **MATE Menu** (the usual upstream title named for this job). Not a transitional dummy, -dev, or docs package, and not an amd64-only package. No exact-version same-source hard Depends existed to bundle. Official different-source range Depends `gir1.2-matemenu-2.0 (>= 1.22)` (source `mate-menus`) stays Depends. Official alternatives `mozo | menulibre` stay Depends. Official Suggests `software-center, synaptic` stay Suggests. Official Replaces `matemenu` is kept. Different-source `mate-menus` / `libmate-menu2` / gir / -dev were inspected and not packaged.

| field | value |
|---|---|
| app_id | **443** |
| package_name | `com.kemi.mate-menu` |
| dpkg | `kemi-mate-menu` |
| mall app_name | MATE Menu |
| official applications desktop Name | (none; official package ships no `/usr/share/applications/*.desktop`; none invented) |
| official applet Name | Advanced MATE Menu (kept in `org.mate.panel.MateMenuApplet.mate-panel-applet`) |
| official GenericName | (none) |
| official appdata `<name>` | (none; official package ships no appdata) |
| official command | `/usr/bin/mate-menu` (Python shebang) |
| official package / source | `mate-menu` / official Source field **absent**, not defaulted |
| mall version_name | `20.04.3-0ubuntu1kemi1` (`len()`==21; no Debian epoch; no tilde; no padding needed) / code **20043** |
| dpkg Version | `20.04.3-0ubuntu1kemi1` |
| bytes | 181452 |
| sha256 | `f40b862075154cb71812c773596b74ce94cac10d37c57095b7e6ef8a374e040a` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794442820108_22c36368_kemi-mate-menu_20_04_3-0ubuntu1kemi1_all.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_20_04_3-0ubuntu1kemi1_all.deb`) |

Official pin (re-confirmed newest pocket on ports https + Aliyun https before CREATE): focal universe Release only `mate-menu_20.04.3-0ubuntu1_all.deb`, Version `20.04.3-0ubuntu1` (no epoch), Size 181000, sha256 `19696c3b61a5188cba4af7437a52173452dadb9261d7fb37c7bad7bc5783c782`. Not in focal-updates / focal-security / focal-backports.

Vacuous 0-ELF probe PASS (Architecture: all Python/GTK panel-applet GUI). Official files stay under `/usr`. `/opt/mate-menu/mate-menu` and `/usr/bin/kemi-mate-menu` are symlinks only to official `/usr/bin/mate-menu`. Official 163 `.mo` and five schemas packed; none invented. Official in-app search-engine PNGs packed at official paths, not used as the mall icon. Official package ships no app icon (theme name `start-here`); 128 evidence PNG is from official U20 humanity-icon-theme 0.6.15 `places/64/start-here.svg` (largest official available; no 128 or scalable start-here in humanity), CREATE-only, theme not bundled. Official changelog and copyright are real files and are kept.

101 smoke is SKIP_TRANSPORT (do not connect, do not touch vibekits). linux-730 recipe PR is left to the parent.

合主线：gork.bot协助开发
