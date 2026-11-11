# Galculator

短描述：Galculator 轻量 GTK3 科学计算器（arm64）

长描述：Galculator 2.1.4 — 轻量 GTK3 科学计算器，支持十进制/十六进制/八进制/二进制、角度制与代数/逆波兰（RPN）模式。官方 Ubuntu 20.04（focal）arm64 deb 重打包；探针 requiredGlibc 2.17（1 ELF），适配 Ubuntu 20.04 / KEMI 101。布局 /opt/galculator + /usr/bin/galculator；界面文件保留在编译路径 /usr/share/galculator/ui。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.3.16）、libglib2.0-0、libpango-1.0-0 和 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 galculator 2.1.4-1build1 in focal arm64（universe）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 galculator_2.1.4-1build1_arm64.deb 重打包为 kemi-galculator；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
