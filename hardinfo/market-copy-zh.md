# HardInfo

短描述：HardInfo 系统信息与基准测试（arm64）

长描述：HardInfo 0.5.1+git20180227-2 — 轻量 GTK2 系统信息与基准测试工具（System Profiler and Benchmark），可查看计算机、设备、网络信息并做简单基准测试。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 5 个 ELF，主程序 requiredGlibc 2.27，四个模块 requiredGlibc 2.17，无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方 ELF 保留在 /usr/bin/hardinfo（二进制内含 binreloc，使用 /proc/self/exe，并编译了 /usr/lib/aarch64-linux-gnu/hardinfo、/usr/share/hardinfo、/usr/share/locale 前缀）；模块、图标、基准数据、帮助和语言文件保留在上述标准路径。/opt/hardinfo/hardinfo 为指向 /usr/bin/hardinfo 的符号链接。官方桌面项 Exec=/usr/bin/hardinfo，图标为随包提供的 /usr/share/hardinfo/pixmaps/logo.png。本官方包语言文件为 de、es、fr、ru（无中文 .mo）。运行时依赖系统 GTK2（libgtk2.0-0 ≥ 2.18.0）、libglib2.0-0 ≥ 2.43.2、libgdk-pixbuf2.0-0 ≥ 2.22.0、libpango-1.0-0 ≥ 1.14.0、libc6 ≥ 2.27、pciutils 以及官方 Depends 中的 zlib1g-dev，均为 Ubuntu 20.04 仓库包；建议安装 lm-sensors，可选 mesa-utils。Launchpad 已发布 hardinfo 0.5.1+git20180227-2 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu disco PROPOSED 构建（build 16201624）后复制进入 focal Release。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 hardinfo_0.5.1+git20180227-2_arm64.deb 重打包为 kemi-hardinfo；探针 5 ELF，主程序 requiredGlibc 2.27，模块 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
