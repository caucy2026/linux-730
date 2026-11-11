# Nautilus

短描述：官方 Ubuntu 20.04 Nautilus 文件管理器（focal-updates，arm64）

长描述：Nautilus 1:3.36.3-0ubuntu1.20.04.2，官方 Ubuntu 20.04（focal-updates main）arm64 软件包的 KEMI 重打包。同一 stanza 亦在 focal-security main；新于 focal Release 1:3.36.1.1-1ubuntu2。同源精确版本硬依赖 libnautilus-extension1a（= 1:3.36.3-0ubuntu1.20.04.2）与 nautilus-data（= 1:3.36.3-0ubuntu1.20.04.2）已捆绑。官方 libnautilus-extension-dev 与 gir1.2-nautilus-3.0 已检查且不打包。官方 /usr/bin/nautilus 等 aarch64 ELF 留在官方路径；/opt/nautilus 下仅为符号链接。另有 /usr/bin/kemi-nautilus → nautilus。不同源依赖保持为 Depends。官方 Recommends（gvfs-backends、librsvg2-common）与 Suggests 保持为 Recommends / Suggests。Debian 纪元 1: 保留在 dpkg Version，并从商城 version_name 与 deb 文件名中省略。探针：6 个独立包装 ELF，requiredGlibc 最高 2.29（6 个有版本需求：1 个 2.29、5 个 2.17；0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，6 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方无 .mo（language-pack 拆分，不发明语言包）。官方应用图标仅为 SVG；商城 CREATE 使用从官方 scalable SVG 栅格化的 128×128 证据 PNG，不打进 deb。官方桌面 Name=Files；商城 app_name=Nautilus。官方桌面 Exec 已改写为 /usr/bin/nautilus --new-window %U；已添加 TryExec=/usr/bin/nautilus。官方 GUI changelog 符号链接在捆绑 lib 文档目录后可解析，真实官方 changelog 亦已用 cp -L 复制。本包提供版本化 Provides: nautilus / libnautilus-extension1a / nautilus-data（= 1:3.36.3-0ubuntu1.20.04.2）。官方来源为 Ubuntu 20.04 focal-updates main nautilus 1:3.36.3-0ubuntu1.20.04.2（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 nautilus 1:3.36.3-0ubuntu1.20.04.2（focal-updates main arm64）。同源精确版本 libnautilus-extension1a 与 nautilus-data 已捆绑。官方 ELF 留在 /usr；/opt 仅为符号链接。纪元 1: 保留在 dpkg Version，并从商城 version_name 与文件名中省略。官方桌面 Name=Files 保持；商城 app_name=Nautilus。官方桌面 Exec 已改写为绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 6 ELF，glibc 最高 2.29，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
