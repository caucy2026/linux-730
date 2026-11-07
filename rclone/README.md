# rclone（KEMI / 101 aarch64）

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.rclone` |
| dpkg | `kemi-rclone` |
| version | `1.76.0-1kemi1` / version_code `176000` |
| upstream | rclone **1.76.0** linux arm64 静态二进制（MIT） |
| upstream zip SHA256 | `ee169016675e23a69d77240565133ff7dbc9b33d16fa8f7053d4af39f1eaeb78` |
| install | `/usr/bin/rclone` + manpage |
| runtime | arm64 static（无 PT_INTERP / 无 dynamic section；无 Docker；适合 101 glibc 2.31） |
| category | 工作 |
| app_id | **134** |
| SHA256 | `74b1cf98edbafcdd27fabc8e544dc95a3e547ab498af75f04ebfe8a581f038c8` |
| size | 18739500 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794026149260_cede823e_kemi-rclone_1_76_0-1kemi1_arm64.deb` |
| 101 smoke | **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待目标 Vibekits 重启后补冒烟 |

## 用途

rclone — 「云端的 rsync」。支持 S3 / Google Drive / OneDrive / WebDAV 等数十种后端。静态 aarch64 二进制，无 Docker。

## 上游

- rclone `1.76.0` linux arm64 **static**
- https://github.com/rclone/rclone/releases/tag/v1.76.0
- zip SHA256: `ee169016675e23a69d77240565133ff7dbc9b33d16fa8f7053d4af39f1eaeb78`
- **巨大二进制不进 git**；构建时从上游下载

## Artifact

见 `rclone-meta.env` / `deb-info.txt`（box 证据路径勿提交二进制）。

## 构建

```bash
./scripts/build-rclone-kemi-deb.sh
```

## 真机冒烟（硬门）

101 冒烟本轮 **BLOCKED_TRANSPORT**（禁止 connect RID `7634801763`）。待用户授权重启目标 Vibekits 后由 parent 补冒烟。**验证 ≠ 编译**；box 上 qemu 跑 `--version` 不算真机 PASS。

## 商场

`os_type=linux` · `linuxpkg`。app134 `com.kemi.rclone` `1.76.0-1kemi1`。CDN 见上表。101 冒烟仍为 **BLOCKED_TRANSPORT**，待目标 Vibekits 重启后补硬门 PASS。
