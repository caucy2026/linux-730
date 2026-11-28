# OpenResearch（商场文案）

短：OpenResearch 终端 research agent（Linux arm64）。上游 CLI v0.2.30 官方静态 musl 二进制重打包。gork.bot协助开发。

长：OpenResearch（alphaXiv/OpenResearch）是本机优先的 research agent 运行时，可检索文献、提出假设、跑实验并产出研究产物。本包只收录官方 `openresearch-cli-aarch64-unknown-linux-musl.tar.gz` v0.2.30（静态 aarch64 EXEC，无 PT_INTERP / 无 glibc NEEDED），适用于 Ubuntu 20.04 aarch64（KEMI 101）。官方 Linux 桌面 AppImage 标明需要 glibc 2.35+，未收录。MIT 许可。需用户自备上游文档中的账号或密钥。合主线：gork.bot协助开发。安装后提供 /usr/bin/orx 与 /usr/bin/openresearch。
