# KD 商场文案草稿（CREATE 前须 101 真机冒烟 PASS）

## kemi-cloudflared
- package_name 建议：`com.kemi.cloudflared` 或 `com.caucy.cloudflared`
- summary：Cloudflare 反向隧道客户端（arm64）
- description：
  把本机 HTTP 服务经 Cloudflare Tunnel 暴露到域名或临时 HTTPS URL。无需公网 IP、无需路由器开端口、不依赖 P2P。设备需能出网访问 Cloudflare；国内线路可能不稳定。含 Quick Tunnel 冒烟示例。合主线 gork.bot协助开发。

## kemi-frp
- package_name 建议：`com.kemi.frp` 或 `com.caucy.frp`
- summary：frpc/frps 自建反向隧道（arm64）
- description：
  用 frpc 连接自建云机 frps，将本机服务经中继暴露；适合国内自建中继。无需公网 IP / 开端口 / P2P。包内含 frps 便于本机环回冒烟与示例 conf（无真实 token）。合主线 gork.bot协助开发。
