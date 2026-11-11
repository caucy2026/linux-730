# Gnumeric

短描述：Gnumeric 电子表格（arm64）

长描述：Gnumeric 1.12.46 — 面向 GNOME 桌面的电子表格，可与 Excel、ODS、CSV 等多种格式互操作。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源精确版本硬依赖 gnumeric-common（= 1.12.46-1ubuntu2）。探针 47 个 ELF：启动器与 ssconvert 等工具 requiredGlibc 2.17、无 GLIBCXX；libspreadsheet 与部分插件 requiredGlibc 2.29、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方启动器与 ssconvert/ssdiff/ssindex/ssgrep 保留在 /usr/bin，libspreadsheet 与内置插件保留在官方 /usr/lib 路径；/opt/gnumeric 下仅为符号链接。桌面项、手册、官方 122 个 .mo（含 zh_CN）、模板、图标、pixmaps 与 GSettings schema 保留在标准路径。官方桌面图标为 gnumeric（本包随带 hicolor 图标与 pixmaps）。官方 Recommends gnumeric-doc、evince、lp-solve 保持为推荐，未捆绑。官方 Suggests gnumeric-plugins-extra（该插件 Depends: gnumeric (= 1.12.46-1ubuntu2)，但仅为建议且依赖 libpython2.7）未捆绑，本包提供版本化 Provides 以便日后独立安装。官方来源为 Ubuntu 20.04 focal universe arm64 gnumeric 1.12.46-1ubuntu2 与同源 gnumeric-common；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 gnumeric_1.12.46-1ubuntu2_arm64.deb 与同源精确版本 gnumeric-common 重打包为 kemi-gnumeric；探针 47 ELF，libspreadsheet requiredGlibc 2.29、无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
