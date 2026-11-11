# Seahorse

短描述：Seahorse 密码和密钥（arm64）

长描述：Seahorse 3.36 — GNOME 官方密码和密钥管理器（GnuPG 前端，亦可管理 SSH 密钥与密钥环）。官方 Ubuntu 20.04（focal main，无更新的 focal-updates 二进制）arm64 当前正式包重打包。探针 3 个 ELF：主程序 requiredGlibc 2.28、无 GLIBCXX；助手 ssh-askpass / xloadimage requiredGlibc 2.17、无 GLIBCXX；适配 Ubuntu 20.04 / KEMI 101。官方 ELF 因编译前缀绑定 /usr（/usr/share/locale、/usr/libexec/seahorse、/usr/bin/gpg、/usr/bin/ssh），保留在 /usr/bin 与 /usr/libexec；/opt/seahorse 下仅为符号链接。桌面项、官方 D-Bus 服务、gschema、手册、metainfo、GNOME Shell 搜索提供者、官方帮助树与图标保留在标准路径。官方桌面图标为 org.gnome.seahorse.Application（本包随带 SVG）。官方语言包拆分：本 deb 不含 .mo；C 帮助为实文件，其他帮助语言为官方 help-langpack 符号链接，未捆绑 language-pack。运行时依赖系统 GTK3、libhandy、libsecret、libgcr、libgpgme、gcr、gnome-keyring、gnupg、avahi、libsoup、libldap、libc6 ≥ 2.28，均为 Ubuntu 20.04 仓库包。官方 Recommends openssh-client 保留为推荐依赖、未捆绑。官方来源为 Ubuntu 20.04 focal main arm64 seahorse 3.36-1；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal main Packages stanza 核对一致。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 seahorse_3.36-1_arm64.deb（focal main）重打包为 kemi-seahorse；探针 3 ELF，requiredGlibc 2.28 / 2.17，无 GLIBCXX。合主线：gork.bot协助开发

合主线：gork.bot协助开发
