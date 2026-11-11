# Gucharmap

短描述：Gucharmap 字符映射表（arm64）

长描述：Gucharmap 13.0.1 — 轻量 GTK3 Unicode 字符选择与字体浏览工具，可按 Unicode 名称或码位查找特殊字符。官方 Ubuntu 20.04（focal）arm64 Release 包重打包；探针 requiredGlibc 2.17（1 ELF），无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。布局 /opt/gucharmap + /usr/bin/gucharmap；语言包、帮助、桌面项、手册、metainfo 和 GSettings schema 保留在 /usr/share。官方桌面图标为 accessories-character-map（主题图标，本包未内置）。运行时依赖系统 GTK3（libgtk-3-0 ≥ 3.4.0）、libgucharmap-2-90-7（= 1:13.0.1-1）、libatk1.0-0、libcairo2、libpango-1.0-0、libpangocairo-1.0-0、libglib2.0-0 ≥ 2.37.3、libc6 ≥ 2.17 以及 gsettings 后端，均为 Ubuntu 20.04 仓库包。Launchpad 已发布 gucharmap 1:13.0.1-1 in focal arm64（universe, Release）；该 arm64 二进制在 ubuntu focal PROPOSED 构建后进入 Release。建议安装 yelp 以阅读帮助。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gucharmap_13.0.1-1_arm64.deb（epoch 1:13.0.1-1）重打包为 kemi-gucharmap；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
