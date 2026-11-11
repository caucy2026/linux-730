# Meld (KEMI Linux)

Graphical file and directory diff/merge tool for KEMI mall (arch=all, Ubuntu 20.04 / 101).

| field | value |
|---|---|
| app_id | **326** |
| package_name | `com.kemi.meld` |
| dpkg | `kemi-meld` |
| version | `3.22.3-1kemi1` / code **3223** |
| bytes | 548316 |
| sha256 | `1844e839d1d9f5205cc8100a0a5e6fbb510fa15317b054321c3af49f63dc1d41` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794385819264_b7b2e4b5_kemi-meld_3_22_3-1kemi1_all.deb |

Notes: official Ubuntu/Debian `meld_3.22.3-2_all.deb` v3.22.3 (591508 B, sha256 `c83842cd5ea7c2d228425e98d04d7c1bc8cffeafdc26706a5b7c11fa895a92b2`). Installs under `/opt/meld/` + `/usr/bin/meld` (symlink to `/opt/meld/bin/meld`). Official DATADIR `/usr/share/meld` rewritten to `/opt/meld/share/meld`; launcher prepends `/opt/meld/lib/python3/dist-packages` so `import meld` works off the system python path. Probe: 0 ELF (Python + GTK3 typelibs + data). Runtime Depends: `python3`, `python3-gi (>= 3.20)`, `python3-gi-cairo`, `gir1.2-gtk-3.0`, `gir1.2-gtksource-4`, `patch`, `dconf-gsettings-backend | gsettings-backend` — all in Ubuntu 20.04 focal arm64 (python3 3.8.2, python3-gi 3.36.0, gir1.2-gtksource-4 4.6.0 main). Official launcher requires Python 3.6 / Gtk 3.20 / GLib 2.48 / GtkSource 4.0 / pygobject 3.30 / pycairo 1.15. Meld 3.24.1 official all.deb was not used (PEP 585 typings `dict[int, str]` / `tuple[...]` without `from __future__ import annotations` would fail at import on Python 3.8). Recipe-only; no `.deb` in git. L1–L4 PASS. 101 lean smoke: **not attempted** (SKIP_TRANSPORT; prior connect at 2026-11-11 15:42 Asia/Shanghai was transport_timeout; no user retry auth).

合主线：gork.bot协助开发
