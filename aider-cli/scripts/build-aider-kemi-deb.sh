#!/usr/bin/env bash
# Build arm64 Focal xz deb for aider-chat. gork.bot协助开发
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${AIDER_WORK:-/workspace/t132-20261106}"
VER_UP=0.86.2
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-aider
mkdir -p "$WORK"/{py,tree,debs,evidence}
export UV_PYTHON_INSTALL_DIR="$WORK/py"
export UV_PYTHON_INSTALL_BIN=0
uv python install cpython-3.12.16-linux-aarch64-gnu --install-dir "$UV_PYTHON_INSTALL_DIR" --no-bin
uv python install 3.12 --no-bin >/dev/null
rm -rf "$WORK/tree"
mkdir -p "$WORK/tree/opt/kemi-aider"
cp -a "$WORK/py/cpython-3.12.16-linux-aarch64-gnu" "$WORK/tree/opt/kemi-aider/python"
SITE="$WORK/tree/opt/kemi-aider/lib/python3.12/site-packages"
mkdir -p "$SITE"
uv pip install --python 3.12 --python-platform aarch64-manylinux_2_31 --target "$SITE" --compile-bytecode "aider-chat==${VER_UP}"
rm -rf "$SITE/bin"
mkdir -p "$WORK/tree/usr/bin" "$WORK/tree/usr/share/doc/$PKG" "$WORK/tree/DEBIAN"
cat > "$WORK/tree/usr/bin/aider" << 'EOW'
#!/bin/sh
AID_ROOT=/opt/kemi-aider
export PYTHONNOUSERSITE=1
export PYTHONPATH="$AID_ROOT/lib/python3.12/site-packages${PYTHONPATH:+:$PYTHONPATH}"
export PYTHONHOME="$AID_ROOT/python"
exec "$AID_ROOT/python/bin/python3.12" -m aider "$@"
EOW
chmod 0755 "$WORK/tree/usr/bin/aider"
cat > "$WORK/tree/usr/bin/aider-chat" << 'EOW'
#!/bin/sh
exec /usr/bin/aider "$@"
EOW
chmod 0755 "$WORK/tree/usr/bin/aider-chat"
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
Recommends: git
Provides: aider
Conflicts: aider
Replaces: aider
Description: Aider AI pair-programming Agent (arm64)
 Terminal coding Agent (aider-chat ${VER_UP}) for KEMI Linux.
 Bundles CPython 3.12 + dependencies. Requires user LLM credentials.
 No Docker. gork.bot协助开发.
EOT
chmod 0755 "$WORK/tree/opt/kemi-aider/python/bin/python3.12"
DEB="$WORK/debs/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb -Zxz --root-owner-group --build "$WORK/tree" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
cp -a "$DEB.sha256" "$ROOT/" || true
echo "DEB=$DEB"
