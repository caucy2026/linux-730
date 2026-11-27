# oh-my-pi（商场文案）

短：oh-my-pi 终端 coding agent（Linux arm64）。上游 gnu 二进制 v19.2.1 重打包。gork.bot协助开发。

长：oh-my-pi（can1357/oh-my-pi）是本机终端 coding agent。本包为官方 Linux arm64 gnu 发行物 v19.2.1 的 KEMI 重打包（MAX_GLIBC 2.17）。与已上架的 pi-bolt（badlogic/pi-mono）不是同一项目。未使用官方 musl 构建（动态依赖 `/lib/ld-musl-aarch64.so.1`，101/U20 没有 musl 动态加载器）。需用户自备 API Key。合主线：gork.bot协助开发。安装后提供 `/usr/bin/omp` 与 `/usr/bin/oh-my-pi`。
