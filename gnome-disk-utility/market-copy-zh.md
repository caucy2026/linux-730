# GNOME Disks

短描述：GNOME Disks 磁盘工具（arm64）

长描述：GNOME Disks 3.36.3 — GNOME 官方磁盘与介质管理工具（格式化/分区、挂载、S.M.A.R.T. 查询，基于 udisks）。官方 Ubuntu 20.04（focal-updates，新于 Release 3.36.1）arm64 当前正式包重打包。探针 3 个 ELF：requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101。官方二进制为 gnome-disks、gnome-disk-image-mounter 与 /usr/libexec/gsd-disk-utility-notify。ELF 因 gettext 前缀绑定 /usr/share/locale（界面为嵌入的 GResource），保留在 /usr/bin 与 /usr/libexec；/opt/gnome-disk-utility 下仅为符号链接。桌面项、D-Bus 服务、官方自动启动 conffile（OnlyShowIn=GNOME; NoDisplay=true）、gschema、手册、metainfo 与图标保留在标准路径。官方桌面图标为 org.gnome.DiskUtility（本包随带 SVG）。官方语言包拆分：本 deb 不含 .mo，未捆绑 language-pack。运行时依赖系统 udisks2、GTK3、libcanberra-gtk3、pango、cairo、libnotify、libsecret、libpwquality、liblzma、libsystemd、libudisks2、dconf/gsettings 后端与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。官方来源为 Ubuntu 20.04 focal-updates main arm64 gnome-disk-utility 3.36.3-0ubuntu1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gnome-disk-utility_3.36.3-0ubuntu1_arm64.deb（focal-updates）重打包为 kemi-gnome-disk-utility；探针 3 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
