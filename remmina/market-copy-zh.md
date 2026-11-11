# Remmina

短描述：Remmina 远程桌面客户端（arm64）

长描述：Remmina 1.4.25 — GTK+ 官方远程桌面客户端，支持 RDP、VNC 与 SSH。官方 Ubuntu 20.04（focal-updates main，新于 Release 1.4.2，Depends 仍 U20 兼容）arm64 当前正式包重打包，并捆绑同源硬依赖 remmina-common，以及官方 Recommends 的 rdp/vnc/secret 插件（同版本官方插件 Depends remmina 精确版本，无法再对 kemi-remmina 单独安装；为使商场包能作为远程桌面客户端使用而捆绑）。官方 Suggests 的 exec/kwallet/spice/www 插件未捆绑（避免拉入 KF5/Qt、webkit、spice）。探针 4 个 ELF：主程序 remmina 与三个插件均 requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr（/usr/share/locale、/usr/lib/aarch64-linux-gnu/remmina/plugins、/usr/share/remmina），包装脚本亦硬编码 /usr/bin/remmina，因此官方文件保留在 /usr/bin 与插件目录；/opt/remmina 下仅为符号链接。桌面项、MIME、手册、metainfo、主题、external_tools 与图标保留在标准路径。官方桌面图标为 org.remmina.Remmina（本包随带 PNG/SVG）。官方语言包拆分：本 deb 不含 .mo 与帮助文档；桌面文件自身含简体中文。官方包不附带 /usr/share/remmina/ui（界面编译进主程序）。运行时依赖系统 GTK3、libssh、libfreerdp2、libvncclient、libsecret、libvte、libappindicator、avahi、libc6 ≥ 2.17 等 Ubuntu 20.04 仓库包。官方来源为 Ubuntu 20.04 focal-updates main arm64 remmina 1.4.25+dfsg-0ubuntu0.20.04.1 及对应 common/插件；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。商场/dpkg 版本名缩短为 1.4.25+dfsg-20.04.1kemi1（完整官方版本串加 kemi1 超出版本名字段长度）。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 remmina_1.4.25+dfsg-0ubuntu0.20.04.1_arm64.deb（focal-updates）加捆绑同源 remmina-common 与官方 Recommends 插件 rdp/vnc/secret，重打包为 kemi-remmina；探针 4 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
