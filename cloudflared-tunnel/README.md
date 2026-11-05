# cloudflared-tunnel（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

本机 HTTP → `cloudflared` → Cloudflare 边缘 → 公网域名/临时 `trycloudflare.com`。
无需公网 IP、路由器开端口、P2P；需设备出网可达 Cloudflare。

## 上游

- cloudflared `2026.10.7` linux-arm64
- 官方资产：https://github.com/cloudflare/cloudflared/releases/tag/2026.10.7
- 二进制 SHA256 见 `SHA256SUMS-upstream.txt` / deb `.sha256`（**巨大二进制不进 git**，构建时从上游下载或用 box 证据目录）

## 构建

```bash
# 先按 scripts 下载 upstream arm64 到 ../upstream/
./scripts/build-cloudflared-kemi-deb.sh
```

## 真机冒烟（硬门）

必须在 101（或同代 aarch64）安装后跑 `scripts/smoke-cloudflared-frp-on-101.sh`；
**box qemu `--version` ≠ 真机公网隧道 PASS**。

## 商场

`os_type=linux` · `linuxpkg` · 独立货架（勿覆盖 Vibekits app90）。
文案见 `market-copy-zh.md`。CREATE 仅在真机冒烟 PASS 后。
