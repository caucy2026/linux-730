# frp-tunnel（KEMI / 101 aarch64）

合主线注明：**gork.bot协助开发**。

## 用途

`frpc`（设备）主动连自建云机 `frps`，反向隧道暴露本机服务。适合国内自建中继；不依赖 P2P / 公网 IP / 家宽开端口。

## 上游

- frp `v0.72.0` `linux_arm64`
- https://github.com/fatedier/frp/releases/tag/v0.72.0
- 校验：`frp_sha256_checksums.txt` 中 `frp_0.72.0_linux_arm64.tar.gz`

## 构建

```bash
./scripts/build-frp-kemi-deb.sh
```

巨大二进制不进 git。示例 conf **不含**真实 token。

## 真机冒烟

本机环回 frps+frpc 映射后 curl 通；见上层 `smoke-on-101.sh`。CREATE 商场前必须真机 PASS。
