#!/usr/bin/env bash
# Rebuild OpenClaw CLI arm64 .deb with bundled Node 26.13.0 + openclaw@2026.10.10.
# gork.bot协助开发 — verification ≠ compilation; do not kill device vibekits.
# Do not commit the .deb or Node tarball into git.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
NODE_VER="${NODE_VER:-26.13.0}"
OPENCLAW_VER="${OPENCLAW_VER:-2026.10.10}"
DEB_VER="${DEB_VER:-${OPENCLAW_VER}-1kemi1}"
OUT_DEB="${1:-$PWD/openclaw-cli_${DEB_VER}_arm64.deb}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

: "${NODE_TAR:?set NODE_TAR to node-v${NODE_VER}-linux-arm64.tar.xz}"
test -f "$NODE_TAR"

export OMP_NUM_THREADS="${OMP_NUM_THREADS:-3}"
export npm_config_jobs="${npm_config_jobs:-2}"

# Stage prefixes as they land on device
mkdir -p "$WORK/extract/opt/openclaw-node" \
         "$WORK/extract/opt/openclaw" \
         "$WORK/extract/usr/bin" \
         "$WORK/extract/DEBIAN"

tar -xJf "$NODE_TAR" -C "$WORK/extract/opt/openclaw-node" --strip-components=1
NODE_BIN="$WORK/extract/opt/openclaw-node/bin/node"
NPM_BIN="$WORK/extract/opt/openclaw-node/bin/npm"
"$NODE_BIN" -v
"$NPM_BIN" -v

export PATH="$WORK/extract/opt/openclaw-node/bin:$PATH"
export npm_config_prefix="$WORK/extract/opt/openclaw"

NPM_MAJOR=$("$NPM_BIN" -v | cut -d. -f1)
NPM_MINOR=$("$NPM_BIN" -v | cut -d. -f2)
ALLOW=()
if [ "$NPM_MAJOR" -ge 12 ] || { [ "$NPM_MAJOR" -eq 11 ] && [ "$NPM_MINOR" -ge 16 ]; }; then
  ALLOW=(--allow-scripts=openclaw)
fi
"$NPM_BIN" install -g "openclaw@${OPENCLAW_VER}" "${ALLOW[@]}"

install -m 0755 "$ROOT/wrappers/usr-bin-openclaw" "$WORK/extract/usr/bin/openclaw"
# ensure prefix bin symlink exists (npm usually creates it)
if [ ! -e "$WORK/extract/opt/openclaw/bin/openclaw" ]; then
  ln -sfn ../lib/node_modules/openclaw/openclaw.mjs "$WORK/extract/opt/openclaw/bin/openclaw"
fi

cp "$ROOT/debian/control" "$WORK/extract/DEBIAN/control"
# refresh Installed-Size (KiB)
SIZE_K=$(du -sk "$WORK/extract" | awk '{print $1}')
sed -i "s/^Installed-Size:.*/Installed-Size: ${SIZE_K}/" "$WORK/extract/DEBIAN/control"
sed -i "s/^Version:.*/Version: ${DEB_VER}/" "$WORK/extract/DEBIAN/control"

dpkg-deb --root-owner-group -Zxz -b "$WORK/extract" "$OUT_DEB"
sha256sum "$OUT_DEB"
stat -c '%s %n' "$OUT_DEB"
