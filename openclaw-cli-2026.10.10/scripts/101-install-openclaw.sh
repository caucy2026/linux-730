#!/bin/bash
set -euo pipefail
export OMP_NUM_THREADS=3
export MAKEFLAGS="-j2"
export npm_config_jobs=2
NODE_VER=26.13.0
PREFIX=/opt/openclaw-node
OPENCLAW_PREFIX=/opt/openclaw
TMP=/tmp/openclaw-install-t79
mkdir -p "$TMP" "$PREFIX" "$OPENCLAW_PREFIX"
cd "$TMP"

echo "==== download node $NODE_VER linux-arm64 ===="
TAR="node-v${NODE_VER}-linux-arm64.tar.xz"
URL="https://nodejs.org/dist/v${NODE_VER}/${TAR}"
if [ ! -f "$TAR" ]; then
  curl -fL --retry 3 -o "$TAR" "$URL"
fi
sha256sum "$TAR" | tee /opt/openclaw/node-tarball.sha256
echo "==== extract to $PREFIX ===="
# extract into prefix (strip top dir)
rm -rf "$PREFIX"/*
tar -xJf "$TAR" -C "$PREFIX" --strip-components=1
"$PREFIX/bin/node" -v
"$PREFIX/bin/npm" -v

export PATH="$PREFIX/bin:$PATH"
export npm_config_prefix="$OPENCLAW_PREFIX"
mkdir -p "$OPENCLAW_PREFIX"

echo "==== npm install -g openclaw@latest ===="
# detect npm major for --allow-scripts
NPM_MAJOR=$("$PREFIX/bin/npm" -v | cut -d. -f1)
NPM_MINOR=$("$PREFIX/bin/npm" -v | cut -d. -f2)
ALLOW=()
if [ "$NPM_MAJOR" -ge 12 ] || { [ "$NPM_MAJOR" -eq 11 ] && [ "$NPM_MINOR" -ge 16 ]; }; then
  ALLOW=(--allow-scripts=openclaw)
fi
echo "npm=$("$PREFIX/bin/npm" -v) allow=${ALLOW[*]:-none}"
"$PREFIX/bin/npm" install -g openclaw@latest "${ALLOW[@]}" 2>&1 | tee /opt/openclaw/npm-install.log

# wrapper so PATH finds openclaw without polluting system
cat > /opt/openclaw/openclaw.env <<ENV
export PATH=/opt/openclaw/bin:/opt/openclaw-node/bin:\$PATH
export OMP_NUM_THREADS=3
ENV
ln -sfn /opt/openclaw/bin/openclaw /usr/local/bin/openclaw 2>/dev/null || true

echo "==== versions ===="
which node; node -v
which npm; npm -v
which openclaw || true
openclaw --version || /opt/openclaw/bin/openclaw --version
ls -la /opt/openclaw/bin/ | head
echo INSTALL_DONE
