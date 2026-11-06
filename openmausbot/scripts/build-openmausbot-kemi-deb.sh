#!/usr/bin/env bash
# Build arm64 Focal xz deb for OpenMausBot headless. gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${OMB_WORK:-/workspace/t137-20261106}"
VER_UP=0.1.142
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-openmausbot
TGZ="${OMB_TGZ:-/workspace/t122-20261106/openmausbot-0.1.142.tgz}"
test -f "$TGZ"
mkdir -p "$WORK"/{tree,debs,evidence}
rm -rf "$WORK/tree"
mkdir -p "$WORK/tree/opt/kemi-openmausbot" "$WORK/tree/usr/bin" "$WORK/tree/usr/share/doc/$PKG" "$WORK/tree/DEBIAN"
tar -xzf "$TGZ" -C "$WORK/tree/opt/kemi-openmausbot" --strip-components=1
test -f "$WORK/tree/opt/kemi-openmausbot/cli.js"
cat > "$WORK/tree/usr/bin/openmausbot" << 'EOW'
#!/bin/bash
set -euo pipefail
ROOT=/opt/kemi-openmausbot
NODE=""
for c in /opt/openclaw-node/bin/node "$ROOT/node/bin/node"; do
  if [ -x "$c" ]; then NODE="$c"; break; fi
done
if [ -z "$NODE" ] && command -v node >/dev/null 2>&1; then
  NODE=$(command -v node)
fi
if [ -z "$NODE" ]; then
  echo "openmausbot: need Node >=24 (expected /opt/openclaw-node/bin/node)" >&2
  exit 127
fi
exec "$NODE" "$ROOT/cli.js" "$@"
EOW
chmod 0755 "$WORK/tree/usr/bin/openmausbot"
cat > "$WORK/tree/DEBIAN/postinst" << 'EOP'
#!/bin/bash
set -e
mkdir -p /var/lib/kemi-openmausbot
chmod 755 /var/lib/kemi-openmausbot
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
Description: OpenMausBot headless Agent service (arm64)
 Local-first multi-agent chat shell as headless Node service.
 Upstream OpenMausBot ${VER_UP} npm package; no Linux arm64 Electron.
 Reuses /opt/openclaw-node (Node >=24) when present.
 gork.bot协助开发.
EOT
DEB="$WORK/debs/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb -Zxz --root-owner-group --build "$WORK/tree" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
cp -a "$DEB.sha256" "$ROOT/" || true
echo "DEB=$DEB"
