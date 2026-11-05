#!/usr/bin/env bash
# Build arm64 frpc (+ optional frps) .deb for KEMI linuxpkg. No real tokens.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UP="$ROOT/upstream/frp_0.72.0_linux_arm64"
VER_UPSTREAM=0.72.0
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-frp
mkdir -p "$STAGE/DEBIAN" \
  "$STAGE/usr/bin" \
  "$STAGE/usr/share/doc/$PKG" \
  "$STAGE/usr/share/$PKG/examples" \
  "$STAGE/lib/systemd/system"
install -m 0755 "$UP/frpc" "$STAGE/usr/bin/frpc"
install -m 0755 "$UP/frps" "$STAGE/usr/bin/frps"
cat > "$STAGE/usr/share/$PKG/examples/frpc.toml.example" << 'EOT'
# 示例：连自建云机 frps。填入真实 serverAddr/token 后复制到 /etc/frp/frpc.toml
serverAddr = "YOUR_VPS_IP_OR_HOST"
serverPort = 7000
auth.method = "token"
auth.token = "REPLACE_ME"

[[proxies]]
name = "web"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 8080
EOT
cat > "$STAGE/usr/share/$PKG/examples/frps.toml.example" << 'EOT'
bindPort = 7000
auth.method = "token"
auth.token = "REPLACE_ME"
EOT
cat > "$STAGE/usr/share/doc/$PKG/README.kemi.md" << 'EOT'
# kemi-frp（frpc/frps）

用途：在无公网 IP 的设备上，用 **frpc** 主动连自建云机 **frps**，把本机 HTTP/TCP 服务经中继暴露出去。
适合国内自建中继；不依赖 P2P、不必开路由器入站。

冒烟（本机环回，勿常驻）：
1. 临时起 frps（示例 conf）
2. frpc 把 127.0.0.1:18081 映到本地另一端口
3. curl 通后停进程

合主线：gork.bot协助开发
EOT
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: net
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / caucy2026 <dev@newlinksz.com>
Description: frpc/frps reverse tunnel clients for KEMI devices (arm64)
 Client (frpc) connects to your own frps VPS to expose local services
 without public IP / port-forward / P2P. Includes frps binary for
 loopback smoke tests and examples under /usr/share/$PKG/examples
 (no real tokens). Upstream frp $VER_UPSTREAM.
EOT
mkdir -p "$OUT"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
echo "DEB=$DEB"
