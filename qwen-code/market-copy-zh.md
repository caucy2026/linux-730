# Qwen Code（商场文案）

短：Qwen Code 终端 coding agent（Linux arm64）。上游 CLI v0.28.7 重打包。gork.bot协助开发。

长：Qwen Code（QwenLM/qwen-code）是通义官方终端 coding agent。本包为官方 Linux arm64 发行物 v0.28.7 的 KEMI 重打包（捆绑 Node，去掉非 linux-arm64 的 ripgrep/landlock，以及需要 glibc 2.34 的可选 audio-capture 原生模块；101 上语音采集不可用）。适用于 Ubuntu 20.04 aarch64（KEMI 101）。需用户自备 API Key。合主线：gork.bot协助开发。安装后提供 `/usr/bin/qwen`。
