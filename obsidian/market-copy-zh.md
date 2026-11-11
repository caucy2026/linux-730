# Obsidian

短描述：Obsidian 本地优先知识库（arm64）

长描述：Obsidian 1.15.0 — 本地优先 Markdown 知识库。官方 linux arm64 tarball 重打包；glibc≤2.31，适配 Ubuntu 20.04 / KEMI 101。启动器 /usr/bin/obsidian（--no-sandbox）。已去掉 obsidian-cli（GLIBC_2.34）及错误架构 native。

发布说明：首发 KEMI Linux arm64：官方 obsidian-1.15.0-arm64.tar.gz 重打包为 kemi-obsidian；探针 requiredGlibc≤2.25（8 ELFs，已丢 cli/错架构 native）；启动器 --no-sandbox。

合主线：gork.bot协助开发
