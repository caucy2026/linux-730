#!/usr/bin/env bash
# Build arm64 Focal xz deb for Continue CLI (cn). gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${CN_WORK:-/workspace/t138-20261106}"
VER_UP=1.5.47
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-continue-cli
TGZ="${CN_TGZ:-$WORK/dl/cli-${VER_UP}.tgz}"
test -f "$TGZ"
mkdir -p "$WORK"/{stage,tree,debs,evidence}
rm -rf "$WORK/stage" "$WORK/tree"
mkdir -p "$WORK/stage" "$WORK/tree/opt/kemi-continue-cli" "$WORK/tree/usr/bin" "$WORK/tree/usr/share/doc/$PKG" "$WORK/tree/DEBIAN"
tar -xzf "$TGZ" -C "$WORK/stage"
cd "$WORK/stage/package"
npm install --omit=dev --ignore-scripts --no-audit --no-fund --os=linux --cpu=arm64
rm -f media/demo.gif demo.expect 2>/dev/null || true
find dist -name '*.map' -delete 2>/dev/null || true
cp -a . "$WORK/tree/opt/kemi-continue-cli/"
test -f "$WORK/tree/opt/kemi-continue-cli/dist/cn.js"
cat > "$WORK/tree/usr/bin/cn" << 'EOW'
#!/bin/bash
set -euo pipefail
ROOT=/opt/kemi-continue-cli
NODE=""
for c in /opt/openclaw-node/bin/node "$ROOT/node/bin/node"; do
  if [ -x "$c" ]; then NODE="$c"; break; fi
done
if [ -z "$NODE" ] && command -v node >/dev/null 2>&1; then
  NODE=$(command -v node)
fi
if [ -z "$NODE" ]; then
  echo "cn: need Node >=20 (expected /opt/openclaw-node/bin/node)" >&2
  exit 127
fi
exec "$NODE" "$ROOT/dist/cn.js" "$@"
EOW
chmod 0755 "$WORK/tree/usr/bin/cn"
cat > "$WORK/tree/DEBIAN/postinst" << 'EOP'
#!/bin/bash
set -e
mkdir -p /var/lib/kemi-continue-cli
chmod 755 /var/lib/kemi-continue-cli
chmod 755 /usr/bin/cn 2>/dev/null || true
exit 0
EOP
chmod 0755 "$WORK/tree/DEBIAN/postinst"
INSTALLED_SIZE=$(du -sk "$WORK/tree" | awk '{print $1}')
cat > "$WORK/tree/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Depends: libc6 (>= 2.31)
Description: Continue CLI (cn) coding agent (arm64)
 Terminal AI coding agent from Continue (@continuedev/cli ${VER_UP}).
 Reuses /opt/openclaw-node (Node >=20) when present.
 Apache-2.0. gork.bot协助开发.
EOT
DEB="$WORK/debs/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb -Zxz --root-owner-group --build "$WORK/tree" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
cp -a "$DEB.sha256" "$ROOT/" || true
echo "DEB=$DEB"
