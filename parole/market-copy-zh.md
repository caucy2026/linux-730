# Parole

短描述：Parole 媒体播放器（arm64）

长描述：Parole 1.0.5 — Xfce 桌面的官方 GStreamer 媒体播放器，支持本地音视频、字幕、光盘与流媒体，并可通过插件扩展。官方 Ubuntu 20.04（focal）arm64 当前正式包重打包。探针 4 个 ELF：requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr（/usr/share/locale、/usr/share/parole/pixmaps、/usr/share/parole/parole-plugins-0、/usr/lib/aarch64-linux-gnu/parole-0），保留在 /usr/bin/parole；/opt/parole/parole 仅为指向 /usr/bin/parole 的符号链接。官方插件（MPRIS2、托盘、通知）随本包保留在官方 lib 路径。桌面项、手册、metainfo、图标、pixmaps 与 50 种 locale（含 zh_CN / zh_TW）保留在标准路径。官方桌面图标为 parole（本包随带 hicolor apps 图标，含 SVG）。同源的 parole-dev 不是硬依赖，未捆绑。运行时依赖系统 GTK3、GStreamer 插件与库、libxfce4ui-2、libxfce4util、libxfconf、cairo、dbus、libnotify、libtagc0、libx11 与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。官方来源为 Ubuntu 20.04 focal universe arm64 parole 1.0.5-1（focal-updates 无更新二进制）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 parole_1.0.5-1_arm64.deb 重打包为 kemi-parole；探针 4 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
