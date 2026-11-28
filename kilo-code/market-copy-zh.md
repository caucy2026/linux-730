# Kilo Code（商场文案）

短：Kilo Code 终端 coding agent（Linux arm64）。上游 CLI v7.8.40 官方 gnu 二进制重打包。gork.bot协助开发。

长：Kilo Code（Kilo-Org/kilocode）是开源 coding agent，可在 VS Code、JetBrains 与终端使用。本包只收录官方 Linux arm64 CLI 发行物 v7.8.40 的 gnu 构建（MAX_GLIBC 2.17），适用于 Ubuntu 20.04 aarch64（KEMI 101）。官方 musl 包是动态链接（INTERP /lib/ld-musl-aarch64.so.1），101/U20 没有 musl 动态加载器，未收录。官方 VS Code / JetBrains 插件不在本包。MIT 许可。需用户自备模型或平台账号。合主线：gork.bot协助开发。安装后提供 /usr/bin/kilo 与 /usr/bin/kilo-code。
