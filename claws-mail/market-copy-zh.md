# Claws Mail

短描述：Claws Mail 邮件客户端（arm64）

长描述：Claws Mail 3.17.5 — 轻量、快速、可扩展的 GTK+2 电子邮件客户端。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包。探针 1 个 ELF：/usr/bin/claws-mail requiredGlibc 2.17、无 GLIBCXX，适配 Ubuntu 20.04 / KEMI 101。官方二进制保留在 /usr/bin/claws-mail（编译前缀绑定 /usr）；/opt/claws-mail 下仅为符号链接。桌面项、手册与官方图标（hicolor 48/64/128 与 pixmap）保留在标准路径。官方桌面图标为 claws-mail。官方语言包拆分：本包不含 .mo，翻译在推荐包 claws-mail-i18n（Depends 为 >= 而非精确版本），未捆绑、未虚构语言包。同源插件包虽对 claws-mail 有精确版本 Depends，但并非官方 Recommends，故未捆绑；本包提供版本化 Provides: claws-mail (= 3.17.5-2)，便于日后独立安装插件与 claws-mail-i18n。官方 Recommends claws-mail-i18n、xfonts、aspell 保持为推荐。官方来源为 Ubuntu 20.04 focal universe arm64 claws-mail 3.17.5-2；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 claws-mail_3.17.5-2_arm64.deb 重打包为 kemi-claws-mail；探针 1 ELF，requiredGlibc 2.17、无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
