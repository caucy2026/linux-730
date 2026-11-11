# FeatherPad

短描述：FeatherPad 轻量 Qt5 文本编辑器（arm64）

长描述：FeatherPad 0.12.1 — 轻量级 Qt5 纯文本编辑器。官方 Ubuntu 20.04（focal）arm64 deb 重打包；探针 requiredGlibc 2.17（1 ELF），适配 Ubuntu 20.04 / KEMI 101。布局 /opt/featherpad + /usr/bin/featherpad。运行时依赖系统 Qt5（libqt5core5a ≥ 5.12.2 等，Ubuntu 20.04 的 5.12 即可）和 libhunspell-1.7-0。上游 GitHub 仅提供源码、无官方 linux aarch64 包；Debian bullseye 官方 0.17.1 需要 Qt ≥ 5.15.1，未采用。本轮先探测的 Xournal++ 官方 jammy aarch64 因 GLIBC 2.35 未采用。

发布说明：首发 KEMI Linux arm64：官方 Ubuntu 20.04 featherpad_0.12.1-1build1_arm64.deb 重打包为 kemi-featherpad；探针 requiredGlibc 2.17（1 ELF）。合主线：gork.bot协助开发

合主线：gork.bot协助开发
