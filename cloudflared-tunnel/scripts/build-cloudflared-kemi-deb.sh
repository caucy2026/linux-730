#!/usr/bin/env bash
# Build arm64 kemi-cloudflared .deb wrapping upstream binary + KEMI docs/examples.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/upstream/cloudflared-linux-arm64"
VER_UPSTREAM=2026.10.7
VER_DEB="${VER_UPSTREAM}-1kemi1"
OUT="$ROOT/debs"
ARCH=arm64
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
PKG=kemi-cloudflared
mkdir -p "$STAGE/DEBIAN" \
  "$STAGE/usr/bin" \
  "$STAGE/usr/share/doc/$PKG" \
  "$STAGE/usr/share/$PKG/examples"
install -m 0755 "$BIN" "$STAGE/usr/bin/cloudflared"
cat > "$STAGE/usr/share/$PKG/examples/quick-tunnel-smoke.sh" << 'EOT'
#!/usr/bin/env bash
# Quick Tunnel 冒烟：需设备能出网访问 Cloudflare。测完请 Ctrl-C / kill。
set -euo pipefail
python3 -m http.server 18080 --bind 127.0.0.1 &
HPID=$!
trap 'kill $HPID 2>/dev/null || true' EXIT
sleep 1
cloudflared tunnel --url http://127.0.0.1:18080
EOT
chmod +x "$STAGE/usr/share/$PKG/examples/quick-tunnel-smoke.sh"
cat > "$STAGE/usr/share/doc/$PKG/README.kemi.md" << 'EOT'
# kemi-cloudflared

用途：把本机 HTTP 服务经 **Cloudflare Tunnel** 反向隧道暴露到域名或临时 trycloudflare.com URL。
无需公网 IP、无需路由器开端口、不依赖 P2P；设备须能出网访问 Cloudflare。

注意：国内到 Cloudflare 线路可能不稳定；主要服务国内用户时更宜自建 frp 中继。

合主线：gork.bot协助开发
EOT
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: net
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / caucy2026 <dev@newlinksz.com>
Description: cloudflared Cloudflare Tunnel client for KEMI (arm64)
 Expose local HTTP via Cloudflare reverse tunnel without public IP,
 router port-forward, or P2P. Requires outbound reachability to Cloudflare.
 Upstream cloudflared $VER_UPSTREAM. Examples in /usr/share/$PKG/examples.
EOT
mkdir -p "$OUT"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
echo "DEB=$DEB"
