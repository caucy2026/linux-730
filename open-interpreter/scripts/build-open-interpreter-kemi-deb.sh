#!/usr/bin/env bash
# Repackage openinterpreter/openinterpreter rust-v0.0.59
# open-interpreter-package-aarch64-unknown-linux-musl into a Focal xz deb.
# gork.bot协助开发
#
#   ./scripts/build-open-interpreter-kemi-deb.sh
#
# Output: open-interpreter/debs/kemi-open-interpreter_0.0.59-1kemi1_arm64.deb
# Do not commit that .deb or the upstream tarball. The published mall bytes
# are pinned by kemi-open-interpreter_0.0.59-1kemi1_arm64.deb.sha256
# (83387384 bytes). dpkg-deb is not bit-stable across versions; a local
# rebuild may differ from the CDN artifact. Compare, do not overwrite the pin.
#
# Optional (layout tests / already-downloaded tarball):
#   OI_PACKAGE_TAR=/path/to.tar.gz
#   OI_EXPECT_SHA=<sha256>   # overrides SHA256SUMS-upstream.txt; not for release
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER_UPSTREAM=0.0.59
VER_DEB="${VER_UPSTREAM}-1kemi1"
TAG="rust-v${VER_UPSTREAM}"
ARCH=arm64
PKG=kemi-open-interpreter
OUT="$ROOT/debs"
UP="$ROOT/upstream"
ASSET="open-interpreter-package-aarch64-unknown-linux-musl.tar.gz"
URL="https://github.com/openinterpreter/openinterpreter/releases/download/${TAG}/${ASSET}"
PIN="$ROOT/${PKG}_${VER_DEB}_${ARCH}.deb.sha256"
PUBLISHED_SHA=0bbbb9a42c6e566aadcb90bffedc96a59085800f238b86378cdaa4bf7f2eae36
PUBLISHED_BYTES=83387384

mkdir -p "$UP" "$OUT"
TAR="${OI_PACKAGE_TAR:-$UP/$ASSET}"
if [[ -n "${OI_EXPECT_SHA:-}" ]]; then
  echo "WARNING: OI_EXPECT_SHA overrides SHA256SUMS-upstream.txt (not a release build)" >&2
  EXPECT="$OI_EXPECT_SHA"
else
  EXPECT=$(awk '{print $1; exit}' "$ROOT/SHA256SUMS-upstream.txt")
fi
[[ "$EXPECT" == "636fc5e8b76cd4d0fcabcaa53cfa87322da49d7a9b085c2ab23c069baef13718" || -n "${OI_EXPECT_SHA:-}" ]] \
  || { echo "upstream pin drifted: $EXPECT"; exit 1; }

if [[ ! -f "$TAR" ]]; then
  curl -fL --retry 3 -o "$TAR" "$URL"
fi
ACT=$(sha256sum "$TAR" | awk '{print $1}')
[[ "$EXPECT" == "$ACT" ]] || { echo "SHA mismatch $ACT != $EXPECT"; exit 1; }

EXTRACT="$UP/extract"
rm -rf "$EXTRACT"
mkdir -p "$EXTRACT"
tar -xzf "$TAR" -C "$EXTRACT"
if [[ -f "$EXTRACT/bin/interpreter" && -f "$EXTRACT/codex-package.json" ]]; then
  SRC="$EXTRACT"
else
  SRC=""
  for dir in "$EXTRACT"/*; do
    if [[ -d "$dir" && -f "$dir/bin/interpreter" && -f "$dir/codex-package.json" ]]; then
      SRC="$dir"
      break
    fi
  done
  [[ -n "$SRC" ]] || { echo "package layout not found in $ASSET"; find "$EXTRACT" -maxdepth 2 -print; exit 1; }
fi
test -f "$SRC/bin/interpreter"
test -f "$SRC/bin/codex-code-mode-host"
test -f "$SRC/codex-path/rg"
test -f "$SRC/codex-resources/bwrap"
test -f "$SRC/codex-resources/zsh/bin/zsh"
grep -q '"entrypoint": "bin/interpreter"' "$SRC/codex-package.json"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
OPT="$STAGE/opt/kemi-open-interpreter"
mkdir -p "$OPT" "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
cp -a "$SRC"/. "$OPT"/
# Upstream ships bin/i as a second copy of bin/interpreter. The published deb
# replaces that duplicate with a symlink (see copyright).
rm -f "$OPT/bin/i"
ln -s interpreter "$OPT/bin/i"
find "$OPT/bin" -mindepth 1 -maxdepth 1 -type f -exec chmod 0755 {} +
chmod 0755 "$OPT/codex-path/rg" "$OPT/codex-resources/bwrap" "$OPT/codex-resources/zsh/bin/zsh"

cat > "$STAGE/usr/bin/open-interpreter" << 'EOT'
#!/bin/sh
# KEMI wrapper for Open Interpreter (rust). gork.bot协助开发
exec /opt/kemi-open-interpreter/bin/interpreter "$@"
EOT
cat > "$STAGE/usr/bin/interpreter" << 'EOT'
#!/bin/sh
# KEMI wrapper alias for Open Interpreter entrypoint.
exec /opt/kemi-open-interpreter/bin/interpreter "$@"
EOT
chmod 0755 "$STAGE/usr/bin/open-interpreter" "$STAGE/usr/bin/interpreter"

cat > "$STAGE/usr/share/doc/$PKG/README.kemi.md" << 'EOT'
# kemi-open-interpreter

Upstream Open Interpreter rust-v0.0.59 (`open-interpreter-package-aarch64-unknown-linux-musl`),
repackaged for KEMI Linux store.

- Install tree: `/opt/kemi-open-interpreter` (preserves `codex-package.json` layout)
- Wrappers: `/usr/bin/open-interpreter`, `/usr/bin/interpreter`
- Category: 工作
- **Requires your own LLM API key / login** (`interpreter login`). Smoke does NOT ship keys.
- Not an Electron desktop shell — terminal / app-server Agent.
- 合主线：gork.bot协助开发
EOT
cat > "$STAGE/usr/share/doc/$PKG/copyright" << 'EOT'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: open-interpreter
Source: https://github.com/openinterpreter/openinterpreter
Comment: Repackaged for KEMI Linux store (gork.bot协助开发). Official
 aarch64-unknown-linux-musl open-interpreter-package rust-v0.0.59.
 Duplicate bin/i replaced with symlink to bin/interpreter to save space.

Files: *
Copyright: Open Interpreter contributors
License: Apache-2.0
EOT
cat > "$STAGE/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: open-interpreter
Conflicts: open-interpreter
Replaces: open-interpreter
Description: Open Interpreter (local coding Agent, arm64 musl)
 Official openinterpreter rust-v0.0.59 aarch64-unknown-linux-musl
 package, repackaged for KEMI Linux store. Installs under
 /opt/kemi-open-interpreter with /usr/bin/open-interpreter wrapper.
 Terminal Agent: read/edit files, run commands, talk to LLMs.
 Requires user-supplied LLM credentials. Not Electron.
 Ubuntu 20.04 Focal aarch64 (101). gork.bot协助开发.
EOT

DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
BYTES=$(wc -c < "$DEB" | tr -d ' ')
LOCAL_SHA=$(awk '{print $1}' "$DEB.sha256")
echo "DEB=$DEB"
echo "local sha256=$LOCAL_SHA bytes=$BYTES"
echo "published sha256=$PUBLISHED_SHA bytes=$PUBLISHED_BYTES"
if [[ "$LOCAL_SHA" == "$PUBLISHED_SHA" && "$BYTES" == "$PUBLISHED_BYTES" ]]; then
  echo "matches published pin $PIN"
else
  echo "local rebuild differs from published pin (expected across dpkg-deb versions); pin left unchanged"
fi
