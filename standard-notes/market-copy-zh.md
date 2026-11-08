# Standard Notes

短描述：Standard Notes 端到端加密笔记（arm64）

长描述：
Standard Notes 3.202.11 — 面向数字工作者的端到端加密笔记应用。
官方 linux arm64 包，KEMI 重打包；glibc≤2.31（Ubuntu 20.04 / 101）。
启动器 /usr/bin/standard-notes（--no-sandbox）。
合主线：gork.bot协助开发

发布说明：
首发 KEMI 商场：Standard Notes 3.202.11 arm64。
探针 aarch64 · requiredGlibc ≤2.25 PASS（剔除 microtime 错架构预编译）。
Notesnook 因 better_sqlite3.node 需 GLIBC_2.34 跳过。
gork.bot协助开发
