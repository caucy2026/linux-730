#!/bin/bash
set -euo pipefail
export OMP_NUM_THREADS=3
NODE_VER=26.13.0
PREFIX=/opt/openclaw-node
SRC=/tmp/vibekits-simulator-7634801763/node-v${NODE_VER}-linux-arm64.tar.xz
# also accept if uploaded to other vibekits path
if [ ! -f "$SRC" ]; then
  SRC=$(find /tmp -name "node-v${NODE_VER}-linux-arm64.tar.xz" 2>/dev/null | head -1)
fi
test -n "$SRC" && test -f "$SRC"
echo "SRC=$SRC"
sha256sum "$SRC"
mkdir -p "$PREFIX" /opt/openclaw
# clear only openclaw-node contents
rm -rf "$PREFIX"/*
tar -xJf "$SRC" -C "$PREFIX" --strip-components=1
"$PREFIX/bin/node" -v
"$PREFIX/bin/npm" -v
ls -la "$PREFIX/bin/node" "$PREFIX/bin/npm"
echo EXTRACT_DONE
