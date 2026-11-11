# Audacious

短描述：Audacious 音频播放器（arm64）

长描述：Audacious 3.10.1 — 小巧快速的音频播放器，支持 Winamp 皮肤与多种编码。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源精确版本硬依赖 libaudcore5（= 3.10.1-1build1）。探针 3 个 ELF：audacious 与 audtool requiredGlibc 2.17、无 GLIBCXX；libaudcore requiredGlibc 2.27、GLIBCXX 3.4，适配 Ubuntu 20.04 / KEMI 101。官方启动器与 audtool 保留在 /usr/bin，libaudcore 保留在官方 /usr/lib 路径；/opt/audacious 下仅为符号链接。桌面项、手册、官方 45 个 .mo（含 zh_CN）、AUTHORS/COPYING 与图标保留在标准路径。官方桌面图标为 audacious（本包随带 hicolor 48x48 PNG、SVG 与 pixmaps）。异源 audacious-plugins（Depends 为 >= 3.10.1，非精确版本）未捆绑，保留为系统 Depends；皮肤与编解码器 UI 在插件包中，本包未虚构。官方 Recommends unzip 保持为推荐，未捆绑。官方来源为 Ubuntu 20.04 focal universe arm64 audacious 3.10.1-1build1 与同源 libaudcore5；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 audacious_3.10.1-1build1_arm64.deb 与同源 libaudcore5 重打包为 kemi-audacious；探针 3 ELF，libaudcore requiredGlibc 2.27、GLIBCXX 3.4。合主线：gork.bot协助开发

合主线：gork.bot协助开发
