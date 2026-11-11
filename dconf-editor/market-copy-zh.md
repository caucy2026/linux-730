# dconf Editor

短描述：dconf Editor 配置编辑器（arm64）

长描述：dconf Editor 3.36.7 — GNOME 官方图形化编辑器，用于直接查看和修改存储在 dconf 中的桌面配置。官方 Ubuntu 20.04（focal-updates universe，新于 Release 3.36.0，Depends 仍 U20 兼容）arm64 当前正式包重打包。无同源 common/data 包。探针 1 个 ELF：requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr/share/locale（界面编译进主程序），保留在 /usr/bin；/opt/dconf-editor 下仅为符号链接。桌面项、官方 D-Bus 服务、gschema、bash 补全、手册、metainfo 与图标保留在标准路径。官方桌面图标为 ca.desrt.dconf-editor（本包随带 PNG 及 symbolic SVG）。官方语言包拆分：本 deb 不含 .mo 与帮助文档；桌面使用 X-Ubuntu-Gettext-Domain=dconf-editor，未捆绑 language-pack。运行时依赖系统 GTK3、libdconf、glib、dconf-gsettings-backend 与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。官方来源为 Ubuntu 20.04 focal-updates universe arm64 dconf-editor 3.36.7-0ubuntu1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates universe Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 dconf-editor_3.36.7-0ubuntu1_arm64.deb（focal-updates）重打包为 kemi-dconf-editor；探针 1 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
