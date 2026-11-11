# PCManFM

短描述：PCManFM 文件管理器（arm64）

长描述：PCMan File Manager 1.3.1 — 极快、轻量的 GTK+ 2 文件管理器，支持标签式浏览。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包重打包。无同源 common/data 包。探针 1 个 ELF：requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr/share/locale、/usr/share/pcmanfm/ui 与 /usr/lib/aarch64-linux-gnu/pcmanfm，保留在 /usr/bin；/opt/pcmanfm 下仅为符号链接。桌面项、手册、官方 54 个 .mo（含 zh_CN）、官方 UI 文件与 /etc/xdg/pcmanfm/default/pcmanfm.conf 保留在标准路径。官方桌面图标为 system-file-manager 与 user-desktop（主题图标，本包不随带图标，未虚构图标）。libfm-gtk4、libfm4、GTK2 与 shared-mime-info 为异源系统 Depends，未捆绑。官方 Recommends（gvfs、polkit 代理、图标主题）保持为推荐，未捆绑。官方来源为 Ubuntu 20.04 focal universe arm64 pcmanfm 1.3.1-1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 pcmanfm_1.3.1-1_arm64.deb（focal universe）重打包为 kemi-pcmanfm；探针 1 ELF，requiredGlibc 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
