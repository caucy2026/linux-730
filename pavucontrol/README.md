# Pavucontrol (KEMI Linux)

Lightweight GTK3 PulseAudio volume control (mixer) for KEMI mall (arm64, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **343** |
| package_name | `com.kemi.pavucontrol` |
| dpkg | `kemi-pavucontrol` |
| version | `4.0-1build1kemi1` / code **40** |
| bytes | 127964 |
| sha256 | `e783e9dfa02ec5cf6a78eca9e9f56710c45f6750b7c2a19ddb426c5e79140e9a` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794391811625_58ad57c4_kemi-pavucontrol_4_0-1build1kemi1_arm64.deb |

Notes: official Ubuntu 20.04 (focal) Release `pavucontrol_4.0-1build1_arm64.deb` v4.0 (137328 B, sha256 `4fdb6af636fc3b76299ec5254eb998ccf0f13b218c3a027ca1b641a6fbc77496`). Launchpad published `pavucontrol 4.0-1build1 in focal arm64` (universe, Release, binarypub 139499677, published 2020-03-23 08:28:50 Asia/Shanghai). Official file URL: https://launchpad.net/ubuntu/+archive/primary/+files/pavucontrol_4.0-1build1_arm64.deb (librarian https://launchpadlibrarian.net/470202087/pavucontrol_4.0-1build1_arm64.deb; fetched via ubuntu-ports mirror; SHA matched Launchpad `.changes` and librarian in-memory hash). The arm64 binary was built in ubuntu focal PROPOSED (build 18873117, no-change rebuild for libgcc-s1 package-name change) and published to Release. Installs under `/opt/pavucontrol/` + `/usr/bin/pavucontrol` (symlink to `/opt/pavucontrol/pavucontrol`). Locales, desktop, man and compiled-in glade UI stay on standard `/usr/share` paths (`/usr/share/pavucontrol/pavucontrol.glade`). Official desktop `Icon=multimedia-volume-control` (theme icon; not shipped in this deb). Probe: aarch64 · requiredGlibc **2.17** (1 ELF) · requiredGlibcxx **3.4.21** (PASS vs 101 GLIBCXX ≤3.4.28) · GTKMM3 + GDKMM3 + ATKMM + GIOMM + GLIBMM + sigc++-2.0 + canberra-gtk3 + libcanberra + GTK3 + GObject/GLib + libpulse-mainloop-glib + libpulse + libstdc++ / libgcc_s. Runtime Depends: `libatkmm-1.6-1v5 (>= 2.24.0)`, `libc6 (>= 2.17)`, `libcanberra-gtk3-0 (>= 0.25)`, `libcanberra0 (>= 0.16)`, `libgcc-s1 (>= 3.0)`, `libglib2.0-0 (>= 2.16.0)`, `libglibmm-2.4-1v5 (>= 2.54.0)`, `libgtk-3-0 (>= 3.0.0)`, `libgtkmm-3.0-1v5 (>= 3.24.0)`, `libpulse-mainloop-glib0 (>= 0.99.1)`, `libpulse0 (>= 4.0)`, `libsigc++-2.0-0v5 (>= 2.2.0)`, `libstdc++6 (>= 5.2)` — all in Ubuntu 20.04 focal. Recommends: `pulseaudio`. Recipe-only; no `.deb` in git. L1–L4 PASS (CREATE 创建并已上架（免审）; L3 hit on page 1). 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
