# KeePassXC

短描述：KeePassXC 密码管理（arm64）

长描述：KeePassXC 2.4.3 — 开源跨平台密码管理器，用一个主密码（或密钥文件）保护整个加密数据库，并支持自动输入。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式 Qt5 包。focal 同源源码仅此一个二进制包，无 -data/-common 可捆绑；官方控制信息无 Recommends / Suggests。探针 4 个 ELF：/usr/bin/keepassxc 与 keepassxc-cli requiredGlibc 2.29、requiredGlibcxx 3.4.21；keepassxc-proxy requiredGlibc 2.17、requiredGlibcxx 3.4.21；官方自动输入插件 libkeepassx-autotype-xcb.so requiredGlibc 2.17、requiredGlibcxx 3.4。无空 glibc/GLIBCXX 记录。适配 Ubuntu 20.04 / KEMI 101（glibc ≤2.31，GLIBCXX ≤3.4.28）。官方二进制保留在 /usr/bin/keepassxc、keepassxc-cli、keepassxc-proxy，插件保留在 /usr/lib/aarch64-linux-gnu/keepassxc/（编译前缀绑定 /usr 与相对路径 share/keepassxc）；/opt/keepassxc 下仅为符号链接。桌面项、手册、官方 42 个 Qt .qm（含 zh_CN）、hicolor 图标、数据文件、mime 与 AppStream 元数据保留在标准路径。官方桌面图标为 keepassxc。本包提供版本化 Provides: keepassxc (= 2.4.3+dfsg.1-1build1)。官方来源为 Ubuntu 20.04 focal universe arm64 keepassxc 2.4.3+dfsg.1-1build1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。本包不同于先前对上游 KeePassXC 2.8.0-1 aarch64 AppImage（glibc 2.38 / Qt6）的 SKIP。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 keepassxc_2.4.3+dfsg.1-1build1_arm64.deb 重打包为 kemi-keepassxc；探针 4 ELF，requiredGlibc 最高 2.29、requiredGlibcxx 最高 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
