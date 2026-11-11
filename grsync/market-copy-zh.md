# Grsync

短描述：Grsync rsync 图形前端（arm64）

长描述：Grsync 1.2.6 — rsync 的 GTK2 图形前端，用于本地目录同步，覆盖最常用的 rsync 选项。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包。同源源码仅此一个二进制包，无 -data/-common 可捆绑。官方 Recommends ssh-askpass（异源，非精确版本插件依赖）保持为推荐，未捆绑。官方无 Suggests。官方 Description 写明 GTK2，ELF 实际链接 libgtk-x11-2.0.so.0，确认为 GTK2。探针：aarch64，1 个 ELF（/usr/bin/grsync；官方 grsync-batch 为 bash 包装脚本，不是 ELF），requiredGlibc 2.17（1 个有版本需求、0 个空值），无 GLIBCXX（0 个有版本需求、1 个空值），满足 Ubuntu 20.04 / KEMI 101（glibc ≤2.31，GLIBCXX ≤3.4.28）。官方二进制保留在 /usr/bin/grsync（嵌入 /usr/share/grsync/grsync.glade、/usr/share/locale 与 pixmap）；官方 grsync-batch 保留在 /usr/bin/grsync-batch；/opt/grsync 下仅为符号链接。桌面项、手册、官方 18 个 .mo（含 zh，无官方 zh_CN）、官方 glade 界面与官方 pixmap 图标保留在标准路径。官方桌面 Exec 已是绝对路径并保留。官方 pixmap 已有 128×128 PNG，用作商场 CREATE 图标，未另打一份进包。本包提供版本化 Provides: grsync (= 1.2.6-2)。官方来源为 Ubuntu 20.04 focal universe grsync 1.2.6-2（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 grsync_1.2.6-2_arm64.deb 重打包为 kemi-grsync。合主线：gork.bot协助开发

合主线：gork.bot协助开发
