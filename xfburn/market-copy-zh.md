# Xfburn

短描述：Xfburn 光盘刻录（arm64）

长描述：Xfburn 0.6.2 — Xfce 桌面的官方 CD/DVD 刻录应用。官方 Ubuntu 20.04（focal）arm64 当前正式包重打包。探针 1 个 ELF：requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr（/usr/share/locale，UI 位于 /usr/share/xfburn），保留在 /usr/bin/xfburn；/opt/xfburn/xfburn 仅为指向 /usr/bin/xfburn 的符号链接。桌面项、Thunar 发送到、手册、metainfo、图标与 57 种 locale（含 zh_CN / zh_TW）保留在标准路径。官方桌面图标为 stock_xfburn（本包随带 hicolor stock/media 图标，含 SVG）。运行时依赖系统 GTK3、libexo-2、libxfce4ui-2、libxfce4util、libburn4、libisofs6、GStreamer 1.0、libgudev 与 libc6 ≥ 2.17，均为 Ubuntu 20.04 仓库包。官方来源为 Ubuntu 20.04 focal universe arm64 xfburn 0.6.2-1（focal-updates 无更新二进制）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 xfburn_0.6.2-1_arm64.deb 重打包为 kemi-xfburn；探针 1 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
