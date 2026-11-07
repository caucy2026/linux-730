#!/usr/bin/env bash
# Merge kemi-* arm64 debs into kemi-cli-toolkit 1.1.0 (+xh). gork.bot协助开发
set -euo pipefail
WORKROOT=${WORKROOT:-/workspace/t146-20261107}
OUT_DIR="${OUT_DIR:-$WORKROOT/debs}"
WORK="${WORK:-$WORKROOT/merge-tmp}"
STAGE="$WORK/stage"
CTRL="$WORK/control"
rm -rf "$WORK"
mkdir -p "$STAGE" "$CTRL" "$OUT_DIR"

DEBS=(
  /workspace/t116-20261106/debs/kemi-gh_2.103.3-1kemi1_arm64.deb
  /workspace/t116-20261106/debs/kemi-ripgrep_15.2.0-1kemi1_arm64.deb
  /workspace/t116-20261106/debs/kemi-jq_1.8.2-1kemi1_arm64.deb
  /workspace/t117-20261106/debs/kemi-fd_10.5.1-1kemi1_arm64.deb
  /workspace/t117-20261106/debs/kemi-bat_0.26.1-1kemi1_arm64.deb
  /workspace/t119-20261106/debs/kemi-yq_4.54.2-1kemi1_arm64.deb
  /workspace/t120-20261106/debs/kemi-fzf_0.74.5-1kemi1_arm64.deb
  /workspace/t121-20261106/debs/kemi-delta_0.20.1-1kemi1_arm64.deb
  /workspace/t123-20261106/debs/kemi-zoxide_0.10.0-1kemi1_arm64.deb
  /workspace/t124-20261106/debs/kemi-hyperfine_2.0.0-1kemi1_arm64.deb
  /workspace/t125-20261106/debs/kemi-dust_1.2.7-1kemi1_arm64.deb
  /workspace/t126-20261106/debs/kemi-procs_0.14.12-1kemi1_arm64.deb
  /workspace/t127-20261106/debs/kemi-sd_1.1.0-1kemi1_arm64.deb
  /workspace/t128-20261106/debs/kemi-xh_0.26.3-1kemi1_arm64.deb
)

MEMBER_BINS=(); CONFLICTS=(); PROVIDES=()
for deb in "${DEBS[@]}"; do
  test -f "$deb" || { echo "MISSING $deb"; exit 1; }
  pkg=$(dpkg-deb -f "$deb" Package)
  ver=$(dpkg-deb -f "$deb" Version)
  echo "MERGE $pkg $ver <- $deb"
  CONFLICTS+=("$pkg")
  prov=$(dpkg-deb -f "$deb" Provides || true)
  [[ -n "${prov:-}" ]] && PROVIDES+=("$prov")
  tmp="$WORK/extract-$pkg"; rm -rf "$tmp"; mkdir -p "$tmp"
  dpkg-deb -x "$deb" "$tmp"
  (cd "$tmp" && tar cf - .) | (cd "$STAGE" && tar xpf -)
  while IFS= read -r -d '' f; do MEMBER_BINS+=("$(basename "$f")"); done < <(find "$tmp/usr/bin" -maxdepth 1 -type f -executable -print0 2>/dev/null || true)
done

mkdir -p "$STAGE/usr/share/doc/kemi-cli-toolkit"
{
  echo "KEMI CLI Toolkit 1.1.0-1kemi1"
  echo "Merged from individual kemi-* packages. gork.bot协助开发"
  echo "Bump: add xh 0.26.3 (musl aarch64)."
  echo "Members:"
  for deb in "${DEBS[@]}"; do echo " - $(dpkg-deb -f "$deb" Package) $(dpkg-deb -f "$deb" Version)"; done
} > "$STAGE/usr/share/doc/kemi-cli-toolkit/README.kemi.md"

uniq_join() { printf '%s\n' "$@" | awk 'NF' | sort -u | paste -sd, -; }
PROV_STR=$(uniq_join "${PROVIDES[@]}" "${CONFLICTS[@]}" "${MEMBER_BINS[@]}")
CONF_STR=$(uniq_join "${CONFLICTS[@]}" "${MEMBER_BINS[@]}")

cat > "$CTRL/control" << CTRL
Package: kemi-cli-toolkit
Version: 1.1.0-1kemi1
Section: utils
Priority: optional
Architecture: arm64
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Provides: ${PROV_STR}
Conflicts: ${CONF_STR}
Replaces: ${CONF_STR}
Description: KEMI CLI 工具集（gh/rg/jq/fd/bat/yq/fzf/delta/zoxide/hyperfine/dust/procs/sd/xh）
 Bundled arm64 CLI utilities for KEMI Linux store as ONE package (1 KPI).
 Static/self-contained binaries targeting Ubuntu 20.04 Focal (xz members).
 gork.bot协助开发. Bump 1.1.0 adds xh.
CTRL

DEB="$OUT_DIR/kemi-cli-toolkit_1.1.0-1kemi1_arm64.deb"
rm -f "$DEB"
mkdir -p "$STAGE/DEBIAN"; cp "$CTRL/control" "$STAGE/DEBIAN/control"
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
python3 -c 'import subprocess,sys; o=subprocess.check_output(["ar","t",sys.argv[1]],text=True); assert "data.tar.xz" in o; print(o)' "$DEB"
sha=$(sha256sum "$DEB" | awk '{print $1}'); bytes=$(stat -c%s "$DEB")
echo "$sha  $(basename "$DEB")" > "$DEB.sha256"
cat > "$OUT_DIR/toolkit-meta.env" << META
PACKAGE=kemi-cli-toolkit
PACKAGE_NAME=com.kemi.cli-toolkit
APP_ID=123
VERSION=1.1.0-1kemi1
VERSION_CODE=11000
ARCH=arm64
BYTES=$bytes
SHA256=$sha
DEB=$DEB
MEMBERS=${#DEBS[@]}
TOOLS=gh,rg,jq,fd,bat,yq,fzf,delta,zoxide,hyperfine,dust,procs,sd,xh
META
echo "OK $DEB bytes=$bytes sha=$sha members=${#DEBS[@]}"
