# dconf Editor (KEMI Linux)

dconf Editor — graphical editor for dconf settings — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **364** |
| package_name | `com.kemi.dconf-editor` |
| dpkg | `kemi-dconf-editor` |
| version | `3.36.7-0ubuntu1kemi1` / code **3367** |
| bytes | 295060 |
| sha256 | `2f604d5c1719980ab801f3121648c448d656f4a756471e5adb41a4abe4db8866` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794401968931_f24e4c8c_kemi-dconf-editor_3_36_7-0ubuntu1kemi1_a.deb |

Notes: official Ubuntu 20.04 (focal-updates universe) `dconf-editor_3.36.7-0ubuntu1_arm64.deb` v3.36.7 (295396 B, sha256 `56c2cf9bbeece7b3b2bdeee6623919ba98d9239d9d4cb8affa360a2ef328f051`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/universe/d/dconf-editor/` pool files and the Ubuntu 20.04 focal-updates universe arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). This is newer than focal Release `3.36.0-1` and remains U20-compatible (same Depends, libc6 ≥ 2.17). No librarian URL is recorded this run. Changelog: 3.36.7-0ubuntu1 uploaded Thu, 01 Apr 2021 11:09:10 +0200 (2021-04-01 17:09:10 Asia/Shanghai). There is no dconf-editor-common / data or typelib package; this is a single official binary package (source dconf-editor). Official binary is `/usr/bin/dconf-editor`. The official ELF embeds compiled `/usr/share/locale` (UI is compiled into the ELF), so the official ELF stays at `/usr/bin`; `/opt/dconf-editor/*` are only symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/GNOME System Monitor/GParted/Seahorse/Remmina layout). Also `/usr/bin/kemi-dconf-editor` → `dconf-editor`. Official language-pack split: this deb ships no `.mo` and no help; desktop uses `X-Ubuntu-Gettext-Domain=dconf-editor` (language packs not bundled; desktop Name/GenericName/Comment are English in this deb). Desktop, official D-Bus (`Exec=/usr/bin/dconf-editor --gapplication-service`), gschema, bash-completion, man, metainfo and icons stay on standard paths. Official desktop `Icon=ca.desrt.dconf-editor` (PNG sizes + symbolic SVG shipped). KEMI desktop Exec/TryExec rewritten to `/usr/bin/dconf-editor`. Probe: aarch64 · 1 ELF (`/usr/bin/dconf-editor`) · requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK3, libdconf, glib, dconf-gsettings-backend, libc6 ≥ 2.17). No official Recommends/Suggests. Conflicts/Replaces dconf-editor. The KEMI version string `3.36.7-0ubuntu1kemi1` is 21 characters and is under the mall `version_name` limit that rejected Remmina's 33-character string (sibling `3.36.1-0ubuntu0.20.04.1kemi1` at 28 characters succeeded). Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). Store truncated the CDN filename to `…_3_36_7-0ubuntu1kemi1_a.deb` (missing trailing `rm64`); SHA and size still match. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
