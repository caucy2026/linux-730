# OpenClaw CLI (Linux arm64) — KEMI packaging

合主线注明「gork.bot协助开发」。**验证 ≠ 编译**。禁止杀真机 vibekits。

应用类顶层目录：本树只存 **打包说明 / debian control / 重建脚本 / 101 安装冒烟脚本**，**不要**把 `.deb`、Node tarball、`node_modules` 提交进仓。

## Artifact（已上架）

| 项 | 值 |
|---|---|
| package_name | `com.openclaw.cli` |
| app_id | **105** |
| deb | `openclaw-cli_2026.10.10-1kemi1_arm64.deb` |
| version_name / code | `2026.10.10-1kemi1` / `2026101001` |
| bytes | `168761036` |
| sha256 | `e84efdf1a5fe167fd42af8cd0837b4158d847d281393ae1faba41681f041fe46` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793829005852_de8ced68_openclaw-cli_2026_10_10-1kemi1_arm64.deb |
| 上游 | `openclaw@2026.10.10`（npm，commit `7dc3350`）+ Node.js `v26.13.0` linux-arm64 |

## Layout on device

- `/opt/openclaw-node/` — official Node linux-arm64 tree
- `/opt/openclaw/` — `npm_config_prefix` install of openclaw
- `/usr/bin/openclaw` — wrapper → bundled `node` + `openclaw.mjs`

## Rebuild（箱侧）

```bash
export NODE_TAR=/path/to/node-v26.13.0-linux-arm64.tar.xz
# Node tarball SHA256 (official): 406fe3fbde1c054adff8b297c16fdb5af6659db327c1ac8acd46b56ef1af9a92
./rebuild-openclaw-cli-deb.sh ./openclaw-cli_2026.10.10-1kemi1_arm64.deb
```

Expect SHA to match the table when inputs are pinned to the versions above.

## 101 smoke（已 PASS · t79 / t82）

- dpkg -i PASS；`OpenClaw 2026.10.10 (7dc3350)`；`gateway --help` OK
- 短 gateway listen `127.0.0.1:18789` 后停；未 onboard / 未 systemd
- 硬件口径：8×A73 · ≈5.5G · 无 swap；建议 `OMP_NUM_THREADS=3` / npm jobs≤2
- 旁路安装脚本见 `scripts/`（与商场 deb 等价前缀）

## Notes

- 上游源码权威仓：https://github.com/openclaw/openclaw（MIT）
- 本目录是 KEMI Linux 商场适配备份，不是上游镜像
- 商场身份 `(com.openclaw.cli, linux)`；勿覆盖其它货架
