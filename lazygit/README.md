# lazygit（KEMI / 101 aarch64）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.lazygit` |
| dpkg | `kemi-lazygit` |
| version | `0.66.2-1kemi1` / version_code `6602` |
| upstream | lazygit **0.66.2** linux arm64 静态二进制（MIT） |
| upstream tar SHA256 | `79a3161eeb642f0473e23db6341f7baabd4a5933e921a9c1167c5d5c765c41a4` |
| install | `/usr/bin/lazygit` |
| runtime | arm64 static（NO_INTERP；无 Docker） |
| category | 工作 |
| app_id | **135** |
| SHA256 | `9f9f724aaebbfa89ea5e25542514b771c69b8c3b36a5a9e99b636e009008e52d` |
| size | 4591524 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794026653663_07dbfe6e_kemi-lazygit_0_66_2-1kemi1_arm64.deb` |
| 101 smoke | **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待目标 Vibekits 重启后补冒烟 |

## 用途

lazygit — 简单易用的终端 Git TUI。官方 linux_arm64 静态二进制，无 Docker。安装后提供 `/usr/bin/lazygit`。

## 上游

- lazygit `0.66.2` linux arm64 **static**
- https://github.com/jesseduffield/lazygit/releases/tag/v0.66.2
- tar.gz SHA256: `79a3161eeb642f0473e23db6341f7baabd4a5933e921a9c1167c5d5c765c41a4`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

见 `lazygit-meta.env` / `deb-info.txt`（box 证据路径勿提交二进制）。

## 构建

```bash
./scripts/build-lazygit-kemi-deb.sh
```

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待用户授权重启目标 Vibekits 后由 parent 补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。

## 商场

`os_type=linux` · `linuxpkg`。app135 `com.kemi.lazygit` `0.66.2-1kemi1`。CDN 见上表。101 冒烟仍为 **BLOCKED_TRANSPORT**，待目标 Vibekits 重启后补硬门 PASS。
