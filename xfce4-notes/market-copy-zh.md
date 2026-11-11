# XFCE Notes

短描述：XFCE Notes 便笺（arm64）

长描述：XFCE Notes 1.8.1 — Xfce 桌面的官方便笺应用，适合快速便签。官方 Ubuntu 20.04（focal）arm64 当前正式包重打包。探针 3 个 ELF：xfce4-notes 与 xfce4-notes-settings requiredGlibc 2.29、无 GLIBCXX；xfce4-popup-notes requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr（/usr/share/locale、/usr/share/xfce4-notes-plugin），保留在 /usr/bin；/opt/xfce4-notes 下仅为指向 /usr/bin 的符号链接。桌面项、自动启动 conffile（Hidden=true，默认不自启）、图标、GTK2 主题数据与 48 种 locale（含 zh_CN / zh_TW）保留在标准路径。官方桌面图标为 xfce4-notes-plugin（本包随带）。同源的 xfce4-notes-plugin 是面板插件（依赖 xfce4-panel 4.13–4.15），不是本包硬依赖，未捆绑。运行时依赖系统 GTK2、libunique、libxfce4ui-1、libxfce4util、libxfconf、cairo、pango、gdk-pixbuf 与 libc6 ≥ 2.29，均为 Ubuntu 20.04 仓库包。官方来源为 Ubuntu 20.04 focal universe arm64 xfce4-notes 1.8.1-3（focal-updates 无更新二进制）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 xfce4-notes_1.8.1-3_arm64.deb 重打包为 kemi-xfce4-notes；探针 3 ELF，requiredGlibc 2.29 / 2.29 / 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
