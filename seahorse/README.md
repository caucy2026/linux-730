# Seahorse (KEMI Linux)

Seahorse — GNOME passwords and keys (GnuPG front end) — packaged for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **362** |
| package_name | `com.kemi.seahorse` |
| dpkg | `kemi-seahorse` |
| version | `3.36-1kemi1` / code **336** |
| bytes | 365544 |
| sha256 | `083a9f53fa5f00a7150e000fae869b9e09e73949747ffecc027aea2aa949ce3c` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794401244903_67d2b5fd_kemi-seahorse_3_36-1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal main) `seahorse_3.36-1_arm64.deb` v3.36 (367520 B, sha256 `b91a61984e35b6b178ea4f6888a8c7274d92fab898afcf2c4a27bc1c61c54512`). Official file SHA + size matched official `https://ports.ubuntu.com/ubuntu-ports/pool/main/s/seahorse/` pool files and the Ubuntu 20.04 focal main arm64 Packages stanzas (streamed; Aliyun ubuntu-ports mirror used for the fetch). There is no newer binary in focal-updates (streamed universe/main updates indexes had 0 seahorse / Source:seahorse stanzas). No librarian URL is recorded this run. Changelog: 3.36-1 uploaded Fri, 13 Mar 2020 18:23:07 +0100 (2020-03-14 01:23:07 Asia/Shanghai). There is no seahorse-common / data or typelib package; this is a single official binary package (source seahorse). Official binaries are `/usr/bin/seahorse` plus helpers `/usr/libexec/seahorse/{ssh-askpass,xloadimage}`. The official main ELF embeds compiled `/usr` prefixes (`/usr/share/locale`, `/usr/libexec/seahorse`, `/usr/bin/gpg`, `/usr/bin/ssh`, `/usr/bin/ssh-keygen`), so official ELFs stay at `/usr/bin` and `/usr/libexec`; `/opt/seahorse/*` are only symlinks (HardInfo/Xpad/qpdfview/Pluma/Gedit/XFCE Notes/Xfburn/Parole/GNOME Disks/GNOME System Monitor/GParted layout). Also `/usr/bin/kemi-seahorse` → `seahorse`. Official language-pack split: this deb ships no `.mo`; desktop uses `X-Ubuntu-Gettext-Domain=seahorse` (language packs not bundled). C help is real (44 files); other official help locales are symlinks into `/usr/share/help-langpack/` (media SVGs point at C; no zh help in this deb; language packs not bundled). Desktop, official D-Bus (`Exec=/usr/bin/seahorse --gapplication-service`), gschema, GNOME Shell search-provider, man, metainfo and icons stay on standard paths. Official desktop `Icon=org.gnome.seahorse.Application` (SVG shipped). KEMI desktop Exec/TryExec rewritten to `/usr/bin/seahorse`. Probe: aarch64 · 3 ELF · seahorse requiredGlibc **2.28** · no GLIBCXX · ssh-askpass / xloadimage requiredGlibc **2.17** · no GLIBCXX. Runtime Depends match official Ubuntu 20.04 (GTK3, libhandy, libsecret, libgcr, libgpgme, gcr, gnome-keyring, gnupg, avahi, libsoup, libldap, libc6 ≥ 2.28). Official Recommends `openssh-client` kept as Recommends and not bundled. Conflicts/Replaces seahorse. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). CDN filename is complete (not truncated). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
