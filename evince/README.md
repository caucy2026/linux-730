# Evince Document Viewer (KEMI Linux)

Evince Document Viewer — official Ubuntu 20.04 graphical document viewer for the GNOME desktop — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101). Official Ubuntu package name is `evince`. Official GUI stanza Source field is absent and was not defaulted (siblings list `Source: evince`, which was not copied onto kemi). Official Homepage `https://wiki.gnome.org/Apps/Evince` is copied exactly. This is a real official lean GUI (focal-updates main, not a snap stub, not transitional, not -dev/docs-only). Official desktop Name=`Document Viewer` is kept (no official GenericName). Official appdata `<name>Evince</name>` lives in the official GUI package and is packed. Mall app_name is **Evince Document Viewer** (the usual English product title; official desktop Name is the generic “Document Viewer”; the project/repo name `evince` is not used as mall app_name). Already-shipped Atril Document Viewer app453 is a distinct product, not occupancy and not a substitute.

Official same-source `libevdocument3-4` and `libevview3-3` are exact-version hard Depends (`= 3.36.10-0ubuntu1`) and are bundled. Official same-source `evince-common` is a range Depends (`>= 3.36`, `<< 3.37`) and stays Depends, not bundled. Official Recommends, Suggests, Enhances, Breaks, Replaces, and Provides are kept.

| field | value |
|---|---|
| app_id | **454** |
| package_name | `com.kemi.evince` |
| dpkg | `kemi-evince` |
| mall app_name | Evince Document Viewer |
| official desktop Name | Document Viewer (kept); secondary desktop Name=Print Preview (NoDisplay=true kept) |
| official GenericName | none |
| official appdata `<name>` | Evince (in official GUI; packed) |
| official binaries | `/usr/bin/evince`, `/usr/bin/evince-previewer`, `/usr/bin/evince-thumbnailer`, `/usr/libexec/evinced`, nautilus extension `libevince-properties-page.so` |
| official package / source | `evince` / GUI Source field absent and not defaulted |
| mall version_name | `3.36.10-0ubuntu1kemi1` (`len()`==21; no Debian epoch; no tilde) / code **33610** |
| dpkg Version | `3.36.10-0ubuntu1kemi1` |
| bytes | 502548 |
| sha256 | `49db9e9fcdfdf3c0930e1ee55b7dc199d2252e624a11c59854ab305e8a0da5dc` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794477359615_ac43a9b6_kemi-evince_3_36_10-0ubuntu1kemi1_arm64.deb |
| CDN_TRUNCATED | **no** (dots sanitized to underscores; exact stored URL ends `_3_36_10-0ubuntu1kemi1_arm64.deb`) |

Official pin prefers focal-updates when newer than Release: focal-updates main `evince_3.36.10-0ubuntu1_arm64.deb`, Version `3.36.10-0ubuntu1` (no epoch), 237124 B, sha256 `261d15e612e739f63d258a10bc0b02c490875d8e0bf8d653f8fbeb45015c0a89`. Filename `pool/main/e/evince/evince_3.36.10-0ubuntu1_arm64.deb`. Not in focal-security index. Official GUI Source absent. Official Homepage `https://wiki.gnome.org/Apps/Evince`. libglib2.0-0 tightened from GUI `>= 2.41.2` to bundled-lib `>= 2.51.5`. kemi also Provides/Conflicts/Replaces `evince`, `libevdocument3-4`, and `libevview3-3`.

Official `/usr/bin/evince` (and previewer/thumbnailer) stay at official paths; `/opt/evince/*` and `/usr/bin/kemi-evince` are symlinks only. No invented extra kemi launchers. Official relative Exec/TryExec rewritten absolute; `%U` kept; official thumbnailer Exec/TryExec also rewritten absolute. Official GUI schema, appdata, man pages, copyright, apparmor conffiles, dbus/systemd units, nautilus extension, lintian overrides, and official hicolor `org.gnome.Evince` SVG icons packed. Official GUI changelog is a dangling symlink into bundled `libevdocument3-4`; the official symlink is kept (it resolves after bundling) and `cp -L` into the kemi doc dir. Official evince-common in-app icons and help are not packed (0 `.mo` in official common; translations live in language packs). CREATE icon is a 128×128 RGBA evidence PNG from official packaged-tree scalable `org.gnome.Evince.svg` (canvas already 128×128); evidence is CREATE-only and is not packed; official SVG is packed once at the official path. Official apparmor postinst/postrm kept; hooks append desktop-database, gtk-update-icon-cache, glib-compile-schemas, and ldconfig. leftover-x86 clear.

Probe: 14 unique aarch64 ELFs; requiredGlibc 2.29 (14 versioned, 0 null); requiredGlibcxx None (0 versioned, 14 null, not ranked as a max); configuredLimitsSatisfied true. 101 smoke: SKIP_TRANSPORT / not attempted. 合主线：gork.bot协助开发.

This recipe tarball is for the parent’s linux-730 PR. Do not open that PR from the executor. Do not start a second evince.
