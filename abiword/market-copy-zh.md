# AbiWord

短描述：AbiWord 文字处理器（arm64）

长描述：AbiWord 3.0.2 — 小巧高效的文字处理器，支持 ODT、Word 与多种格式插件。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源硬依赖 abiword-common（官方 Depends 为 >= 3.0.2-10，focal 仅此版本）以及官方推荐插件 abiword-plugin-grammar（该插件 Depends: abiword (= 3.0.2-10)，按 Remmina 插件模式捆绑）。探针打包内 46 个 ELF：启动器 stub requiredGlibc 2.17、无 GLIBCXX；插件 requiredGlibc 2.17（eml.so 无 glibc 版本需求）、最高 GLIBCXX 3.4.21，适配 Ubuntu 20.04 / KEMI 101。未捆绑的系统依赖 libabiword-3.0 另探针 requiredGlibc 2.17、GLIBCXX 3.4.26，亦在基线内。官方启动器保留在 /usr/bin，插件保留在官方 /usr/lib 路径；/opt/abiword 下仅为符号链接。桌面项、手册、官方 91 个 strings（含 zh-CN.strings；本包无 gettext .mo，遵循官方语言包拆分，未虚构语言包）、UI、图标、D-Bus 与 Telepathy 文件保留在标准路径。官方桌面图标为 abiword（本包随带 hicolor 图标）。同源共享库 libabiword-3.0（Depends 为 >= 3.0.2，非精确版本）未捆绑，保留为系统 Depends。官方 Recommends aspell-en | aspell-dictionary、fonts-liberation、poppler-utils 保持为推荐，未捆绑。官方来源为 Ubuntu 20.04 focal universe arm64 abiword 3.0.2-10、同源 abiword-common 与 abiword-plugin-grammar；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 abiword_3.0.2-10_arm64.deb 与同源 abiword-common、官方推荐插件 abiword-plugin-grammar 重打包为 kemi-abiword；探针 46 ELF，最高 requiredGlibc 2.17、GLIBCXX 3.4.21。合主线：gork.bot协助开发

合主线：gork.bot协助开发
