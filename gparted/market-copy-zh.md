# GParted

短描述：GParted 分区编辑器（arm64）

长描述：GParted 1.0.0 — GNOME 官方分区编辑器，用于创建、重新组织或删除磁盘分区（libparted）。官方 Ubuntu 20.04（focal main，无更新的 focal-updates 二进制）arm64 当前正式包重打包，并捆绑同源硬依赖 gparted-common。探针 1 个 ELF（gpartedbin）：requiredGlibc 2.17、GLIBCXX 3.4.21，适配 Ubuntu 20.04 / KEMI 101。官方启动器为 /usr/sbin/gparted POSIX 包装脚本，ELF 为 /usr/sbin/gpartedbin；包装脚本与 polkit 策略均硬编码这两个 /usr/sbin 路径，ELF 还嵌入 /usr/share/locale，因此官方文件保留在 /usr/sbin；/opt/gparted 下仅为符号链接。桌面项、polkit 策略、手册、metainfo、官方帮助树与图标保留在标准路径。官方桌面已是 Exec=/usr/sbin/gparted %f，图标为 gparted（本包随带 PNG/SVG）。官方语言包拆分：本 deb 不含 .mo；桌面文件自身含简体/繁体中文等翻译；C 帮助为实文件，其他帮助语言为官方 help-langpack 符号链接，未捆绑 language-pack。运行时依赖系统 GTK3、gtkmm、glibmm、libparted、policykit-1、libstdc++6 与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。官方 Suggests 文件系统工具保留为建议依赖、未捆绑。官方来源为 Ubuntu 20.04 focal main arm64 gparted 1.0.0-0.1build1 与 arch:all gparted-common 1.0.0-0.1build1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gparted_1.0.0-0.1build1_arm64.deb（focal main）加捆绑同源硬依赖 gparted-common_1.0.0-0.1build1_all.deb，重打包为 kemi-gparted；探针 1 ELF，requiredGlibc 2.17，GLIBCXX 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
