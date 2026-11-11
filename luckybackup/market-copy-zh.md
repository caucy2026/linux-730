# luckyBackup

短描述：luckyBackup 备份同步工具（arm64）

长描述：luckyBackup 0.5.0 — 基于 rsync 的图形备份与同步工具，支持排除/仅包含、自定义 rsync 选项、远程连接、还原、演练、计划任务与配置文件。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源精确版本硬依赖 luckybackup-data (= 0.5.0-3build1，Architecture: all)。官方二进制包无 Recommends/Suggests。系统依赖（Qt5、libstdc++6、rsync、libc6）保持为依赖。探针：aarch64，1 个 ELF（/usr/bin/luckybackup），requiredGlibc 2.17（1 个有版本需求、0 个空值），requiredGlibcxx 3.4.21（1 个有版本需求、0 个空值），满足 Ubuntu 20.04 / KEMI 101（glibc ≤2.31，GLIBCXX ≤3.4.28）。官方二进制保留在 /usr/bin/luckybackup（嵌入 /usr/share/luckybackup/translations/ 与官方手册路径）；官方 pkexec 包装脚本保留在 /usr/bin/luckybackup-pkexec；/opt/luckybackup 下仅为符号链接。桌面项、手册、官方 26 个 Qt .qm（含 zh_TW，无官方 zh_CN）、官方 pixmap 图标与官方 HTML 手册保留在标准路径。官方桌面 Exec 与 Icon 已是绝对路径并保留。官方 pixmap 已有 PNG，用作商场 CREATE 图标，未另打一份进包。本包提供版本化 Provides: luckybackup (= 0.5.0-3build1)、luckybackup-data (= 0.5.0-3build1)。官方来源为 Ubuntu 20.04 focal universe luckybackup 0.5.0-3build1（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 luckybackup_0.5.0-3build1_arm64.deb 重打包为 kemi-luckybackup，并捆绑同源精确版本 luckybackup-data。合主线：gork.bot协助开发

合主线：gork.bot协助开发
