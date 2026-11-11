# GNOME To Do

短描述：官方 Ubuntu 20.04 GNOME To Do 待办事项管理工具（focal，arm64）

长描述：GNOME To Do 3.28.1-5，官方 Ubuntu 20.04（focal main）arm64 软件包的 KEMI 重打包。focal-updates / focal-security / focal-backports 无更新包。已捆绑同源精确版本硬依赖 libgnome-todo（= 3.28.1-5；仅为官方 Python 插件，无 ELF）以及官方 GUI 硬依赖、且 focal 仅有该版本的 arch:all 软件包 gnome-todo-common（>= 3.28.1-5；图标、gschema、D-Bus、自启动）。同源 gir1.2-gtd-1.0 与 libgnome-todo-dev 已检查、未打包。官方 /usr/bin/gnome-todo 为 aarch64 ELF，留在官方路径。官方文件留在官方路径；/opt/gnome-todo 下仅为符号链接。另有 /usr/bin/kemi-gnome-todo → gnome-todo。官方 EDS / GOA / GTK / peas / rest / ical / typelib / libc6 等依赖保持为 Depends，未捆绑。官方控制文件无 Recommends、无 Suggests。探针：1 个独立包装 ELF，requiredGlibc 2.17（1 个有版本需求，0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，1 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方无 .mo（不发明语言包）。官方 256×256 hicolor PNG（位于 gnome-todo-common）用于商城 CREATE 图标，仅按官方路径打进 deb，证据副本不二次打包。官方桌面图标为 org.gnome.Todo。官方桌面 Name=To Do；商城 app_name=GNOME To Do。官方桌面 Exec=gnome-todo 已改写为 /usr/bin/gnome-todo；已添加 TryExec=/usr/bin/gnome-todo。官方 D-Bus Exec 已是绝对路径并保持不变。官方 GUI changelog.Debian.gz 为指向已捆绑 lib 文档目录的符号链接，打包后可解析；真实官方 lib changelog 已用 cp -L 复制到 kemi 文档目录。本包提供版本化 Provides: gnome-todo (= 3.28.1-5)、gnome-todo-common (= 3.28.1-5)、libgnome-todo (= 3.28.1-5)。官方来源为 Ubuntu 20.04 focal main gnome-todo 3.28.1-5（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 gnome-todo 3.28.1-5（focal main arm64）。已捆绑 libgnome-todo 与 gnome-todo-common。官方 ELF 留在 /usr；/opt 仅为符号链接。不同源官方依赖未捆绑。官方桌面 Exec 已改写为绝对路径。官方 256×256 图标用于商城 CREATE，仅按官方路径打包。探测 1 ELF，glibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
