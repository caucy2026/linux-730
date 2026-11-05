#!/usr/bin/env bash
# Rebuild VibeKits arm64 .deb with Focal-compatible bundled libstdc++ (conda-forge).
# gork.bot协助开发 — verification ≠ compilation; do not kill device vibekits.
set -euo pipefail
SRC_DEB="${1:?usage: $0 /path/to/VibeKits-…-linux-arm64.deb [out.deb]}"
OUT_DEB="${2:-${SRC_DEB%.deb}-focalrt.deb}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
dpkg-deb -x "$SRC_DEB" "$WORK/extract"
dpkg-deb -e "$SRC_DEB" "$WORK/DEBIAN"
# Expect caller to place libstdc++.so.6.0.30 + libgcc_s.so.1 under FOCALRT_LIBS
: "${FOCALRT_LIBS:?set FOCALRT_LIBS to dir containing libstdc++.so.6.0.30 and libgcc_s.so.1}"
LIBDIR="$WORK/extract/opt/vibekits/lib"
install -m 0755 "$FOCALRT_LIBS/libstdc++.so.6.0.30" "$LIBDIR/"
ln -sfn libstdc++.so.6.0.30 "$LIBDIR/libstdc++.so.6"
install -m 0755 "$FOCALRT_LIBS/libgcc_s.so.1" "$LIBDIR/"
if [ ! -f "$WORK/extract/opt/vibekits/vibekits.real" ]; then
  mv "$WORK/extract/opt/vibekits/vibekits" "$WORK/extract/opt/vibekits/vibekits.real"
fi
cat > "$WORK/extract/opt/vibekits/vibekits" <<'WRAP'
#!/bin/sh
HERE="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
export LD_LIBRARY_PATH="$HERE/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$HERE/vibekits.real" "$@"
WRAP
chmod 0755 "$WORK/extract/opt/vibekits/vibekits"
sed -i 's/libstdc++6 (>= 11)/libstdc++6 (>= 9)/' "$WORK/DEBIAN/control"
mkdir -p "$WORK/extract/DEBIAN"
cp -a "$WORK/DEBIAN/." "$WORK/extract/DEBIAN/"
dpkg-deb --root-owner-group -Zxz -b "$WORK/extract" "$OUT_DEB"
sha256sum "$OUT_DEB"
stat -c '%s %n' "$OUT_DEB"
