# oh-my-pi（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.oh-my-pi` |
| dpkg | `kemi-oh-my-pi` |
| app_name | oh-my-pi |
| version | `19.2.1-1kemi1` / version_code `19021` |
| upstream | can1357/oh-my-pi official `omp-linux-arm64` v19.2.1（T154 时为 v19.2.0 musl；本包用当前 gnu 稳定版） |
| install | `/opt/oh-my-pi/omp` + `/usr/bin/omp` + `/usr/bin/oh-my-pi` |
| category | 工作 |
| app_id | 待商场 CREATE 分配（本回合无凭证，未上架） |
| SHA256 | `85b91c69a4ebb42892f74c87fd9e963a7dea00f065cfcbd9f7e5925be6afc82c` |
| size | 110589156 B |
| ABI | probe PASS：aarch64 gnu，MAX_GLIBC 2.17 |
| CREATE | **blocked** — `/home/box/.kemi-publish` missing |
| 101 smoke | SKIP_TRANSPORT / billing-blocked；未 connect |

## 边界

- 与已上架 `com.kemi.pi-bolt`（badlogic/pi-mono）不是同一项目，也不是它的第二份。
- 官方 `omp-linux-musl-arm64` 为动态 musl（INTERP `/lib/ld-musl-aarch64.so.1`，NEEDED `libc.musl-aarch64.so.1` + `libstdc++.so.6`），101/U20 无法直接运行，故改用官方 gnu 构建。
- 配方目录不含 `.deb`。构建：`OUT=./debs DL=./dl ./scripts/build-oh-my-pi-kemi-deb.sh`
- 用户自备 API Key。

合主线注明「gork.bot协助开发」。
