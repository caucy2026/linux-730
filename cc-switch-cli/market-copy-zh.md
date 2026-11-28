# CC Switch CLI（商场文案）

短：CC Switch CLI（Linux arm64 musl）。上游 v5.11.4 静态二进制重打包。gork.bot协助开发。

长：CC Switch CLI（SaladDay/cc-switch-cli）是 CC Switch 的命令行版本，与桌面版 farion1231/cc-switch 不是同一软件（桌面版因 glibc 2.35+ / WebKitGTK 4.1 不适用于 101）。本包为官方 Linux arm64 musl 发行物 v5.11.4 的 KEMI 重打包（静态 aarch64，无 glibc 依赖）。官方 gnu 构建需要 GLIBC_2.39，未收录。合主线：gork.bot协助开发。安装后提供 `/usr/bin/cc-switch` 与 `/usr/bin/cc-switch-cli`。
