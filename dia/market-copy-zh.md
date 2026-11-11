# Dia

短描述：Dia 图表编辑器（arm64）

长描述：Dia 0.97.3 — 用于绘制 UML、实体关系、网络等技术图表的图形编辑器，可导出为 PostScript 等多种格式。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源精确版本硬依赖 dia-common（= 0.97.3+git20160930-9）。探针 36 个打包 ELF：主程序与 libcairo_filter.so requiredGlibc 2.29、无 GLIBCXX；libdia.so 与其余插件 requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方二进制保留在 /usr/bin/dia，插件与 libdia.so 保留在 /usr/lib/aarch64-linux-gnu/dia/（编译前缀绑定 /usr）；/opt/dia 下仅为符号链接。桌面项、手册、官方 66 个 .mo（含 zh_CN）、hicolor 图标、/usr/share/dia 数据、XML DTD、mime、缩略图脚本与官方 HTML/PDF 手册保留在标准路径。官方桌面图标为 dia。官方 Recommends gsfonts-x11 与异源 dia-shapes（Depends: dia 非精确版本）保持为推荐，未捆绑。本包提供版本化 Provides: dia (= 0.97.3+git20160930-9) 与 dia-common (= 0.97.3+git20160930-9)，便于日后独立安装附加形状。官方来源为 Ubuntu 20.04 focal universe arm64 dia 0.97.3+git20160930-9 与同源 dia-common；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 dia_0.97.3+git20160930-9_arm64.deb 与同源精确版本 dia-common 重打包为 kemi-dia；探针 36 ELF，主程序 requiredGlibc 2.29、无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
