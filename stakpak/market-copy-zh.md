# Stakpak（商场文案）

短：Stakpak 终端自主 agent（Linux arm64）。上游 CLI v0.3.88 官方静态 aarch64 二进制重打包。gork.bot协助开发。

长：Stakpak（stakpak/agent）是本机自主/运维 agent，用来在机器上持续照看应用并在需要时再找人。本包为官方 Linux aarch64 发行物 v0.3.88 的 KEMI 重打包（静态 aarch64 EXEC，无 PT_INTERP / 无动态节 / 无 glibc NEEDED），适用于 Ubuntu 20.04 aarch64（KEMI 101）。Apache-2.0 许可。需用户自备上游文档中的账号或密钥。合主线：gork.bot协助开发。安装后提供 /usr/bin/stakpak。
