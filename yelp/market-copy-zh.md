# Yelp

短描述：官方 Ubuntu 20.04 Yelp GNOME 帮助浏览器（focal-updates，arm64）

长描述：Yelp 3.36.2-0ubuntu1.1，官方 Ubuntu 20.04（focal-updates main）arm64 软件包的 KEMI 重打包。同一 stanza 亦出现在 focal-security main；新于 focal Release 3.36.0-1，依赖仍为 libc6 (>= 2.17)。已捆绑同源精确版本硬依赖 libyelp0（= 3.36.2-0ubuntu1.1；含 libyelp.so.0 与 libyelpwebextension.so）。同源 libyelp-dev 已检查、未打包。官方 /usr/bin/yelp 为 aarch64 ELF，留在官方路径；官方 /usr/bin/gnome-help 为指向 yelp 的符号链接并保持。官方文件留在官方路径；/opt/yelp 下仅为符号链接。另有 /usr/bin/kemi-yelp → yelp。官方 yelp-xsl / webkit / GTK / glib / soup / xml / xslt / python3-distro / man-db 等依赖保持为 Depends，未捆绑。官方 Recommends docbook-xml 保持为 Recommends，未捆绑。官方控制文件无 Suggests。探针：3 个独立包装 ELF，requiredGlibc 2.17（3 个有版本需求，0 个空值，不发明最大值），无 GLIBCXX（0 个有版本需求，3 个空值，空值不作为最大值），无 RUNPATH，符合 Ubuntu 20.04 / KEMI 101（glibc ≤2.31 / GLIBCXX ≤3.4.28）。官方无 .mo（不发明语言包）。官方应用图标仅为 SVG；商城 CREATE 使用从官方 scalable SVG 栅格化的 128×128 证据 PNG，不打进 deb。官方 in-app 状态图标保持官方。官方桌面图标为 org.gnome.Yelp。官方桌面 Name=Help；商城 app_name=Yelp。官方桌面 Exec=yelp %u 已改写为 /usr/bin/yelp %u；已添加 TryExec=/usr/bin/yelp。官方 GUI changelog.Debian.gz 为指向已捆绑 lib 文档目录的符号链接，打包后可解析；真实官方 lib changelog 已用 cp -L 复制到 kemi 文档目录。本包提供版本化 Provides: yelp (= 3.36.2-0ubuntu1.1)、libyelp0 (= 3.36.2-0ubuntu1.1)。官方 libyelp0 的 shlibs / symbols / ldconfig trigger 已保留。官方来源为 Ubuntu 20.04 focal-updates main yelp 3.36.2-0ubuntu1.1（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal-updates main Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首次上架官方 Ubuntu 20.04 yelp 3.36.2-0ubuntu1.1（focal-updates main arm64）。已捆绑 libyelp0。官方 ELF 留在 /usr；/opt 仅为符号链接。不同源官方依赖未捆绑。官方 Recommends docbook-xml 保持。官方桌面 Exec 已改写为绝对路径。从官方 SVG 栅格化的 128×128 证据 PNG 用于商城图标，未打进 deb。探测 3 ELF，glibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发。

合主线：gork.bot协助开发
