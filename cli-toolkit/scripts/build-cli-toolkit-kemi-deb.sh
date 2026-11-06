#!/usr/bin/env bash
# Merge the 13 arm64 kemi-* CLI debs into one xz (Ubuntu 20.04 / Focal) deb.
# gork.bot协助开发
#
# Preferred path — member debs already built (not stored in git):
#   ./scripts/build-cli-toolkit-kemi-deb.sh
# Search order per member:
#   1. $MEMBER_DEB_DIR/<deb filename>
#   2. <repo>/<recipe>/debs/<deb filename>
#   3. <repo>/<recipe>/<deb filename>
#
# Rebuild path — download upstream and run each single-package recipe, then merge.
# Huge binaries stay out of git (each recipe gitignores debs/ and upstream/):
#   REBUILD_MISSING=1 ./scripts/build-cli-toolkit-kemi-deb.sh
#
# Layout check (no download, no pack):
#   ./scripts/build-cli-toolkit-kemi-deb.sh --check-layout
#
# Output: cli-toolkit/debs/kemi-cli-toolkit_1.0.0-1kemi1_arm64.deb
# Do not commit that .deb. The published mall bytes are pinned by
# kemi-cli-toolkit_1.0.0-1kemi1_arm64.deb.sha256 (24595556 bytes).
# dpkg-deb is not bit-stable across versions; a local rebuild may differ
# from the CDN artifact. Compare, do not overwrite the pin.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
VER_DEB=1.0.0-1kemi1
ARCH=arm64
PKG=kemi-cli-toolkit
OUT="$ROOT/debs"
PIN="$ROOT/${PKG}_${VER_DEB}_${ARCH}.deb.sha256"
PUBLISHED_SHA=2d021d1adddbe6ec013341ad86e3666562319ac40211100c23b91fe4261d61c0
PUBLISHED_BYTES=24595556

# member|recipe_dir|deb_filename|build_script|bin
# Keep in sync with cli-toolkit/README.md (former mall app_id 110–122).
MEMBERS=(
  "gh|github-cli|kemi-gh_2.103.3-1kemi1_arm64.deb|scripts/build-gh-kemi-deb.sh|gh"
  "ripgrep|ripgrep-cli|kemi-ripgrep_15.2.0-1kemi1_arm64.deb|scripts/build-ripgrep-kemi-deb.sh|rg"
  "jq|jq-cli|kemi-jq_1.8.2-1kemi1_arm64.deb|scripts/build-jq-kemi-deb.sh|jq"
  "fd|fd-cli|kemi-fd_10.5.1-1kemi1_arm64.deb|scripts/build-fd-kemi-deb.sh|fd"
  "bat|bat-cli|kemi-bat_0.26.1-1kemi1_arm64.deb|scripts/build-bat-kemi-deb.sh|bat"
  "yq|yq-cli|kemi-yq_4.54.2-1kemi1_arm64.deb|scripts/build-yq-kemi-deb.sh|yq"
  "fzf|fzf-cli|kemi-fzf_0.74.5-1kemi1_arm64.deb|scripts/build-fzf-kemi-deb.sh|fzf"
  "delta|delta-cli|kemi-delta_0.20.1-1kemi1_arm64.deb|scripts/build-delta-kemi-deb.sh|delta"
  "zoxide|zoxide-cli|kemi-zoxide_0.10.0-1kemi1_arm64.deb|scripts/build-zoxide-kemi-deb.sh|zoxide"
  "hyperfine|hyperfine-cli|kemi-hyperfine_2.0.0-1kemi1_arm64.deb|scripts/build-hyperfine-kemi-deb.sh|hyperfine"
  "dust|dust-cli|kemi-dust_1.2.7-1kemi1_arm64.deb|scripts/build-dust-kemi-deb.sh|dust"
  "procs|procs-cli|kemi-procs_0.14.12-1kemi1_arm64.deb|scripts/build-procs-kemi-deb.sh|procs"
  "sd|sd-cli|kemi-sd_1.1.0-1kemi1_arm64.deb|scripts/build-sd-kemi-deb.sh|sd"
)

if [[ "${1:-}" == "--check-layout" ]]; then
  fail=0
  for row in "${MEMBERS[@]}"; do
    IFS='|' read -r name recipe deb script bin <<<"$row"
    for path in \
      "$REPO_ROOT/$recipe/$script" \
      "$REPO_ROOT/$recipe/${deb}.sha256"
    do
      if [[ ! -f "$path" ]]; then
        echo "missing $path" >&2
        fail=1
      fi
    done
    [[ -n "$name" && -n "$bin" ]] || { echo "bad member row: $row" >&2; fail=1; }
  done
  [[ "$fail" -eq 0 ]] || exit 1
  echo "layout OK (${#MEMBERS[@]} members)"
  exit 0
fi

find_member_deb() {
  local recipe="$1" deb="$2"
  local candidate
  if [[ -n "${MEMBER_DEB_DIR:-}" && -f "$MEMBER_DEB_DIR/$deb" ]]; then
    printf '%s\n' "$MEMBER_DEB_DIR/$deb"
    return 0
  fi
  for candidate in \
    "$REPO_ROOT/$recipe/debs/$deb" \
    "$REPO_ROOT/$recipe/$deb" \
    "$ROOT/members/$deb"
  do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

verify_member_sha() {
  local recipe="$1" deb="$2" path="$3"
  local shafile="$REPO_ROOT/$recipe/${deb}.sha256"
  [[ "${VERIFY_MEMBER_SHA:-1}" == "1" ]] || return 0
  [[ -f "$shafile" ]] || { echo "missing sha pin $shafile" >&2; return 1; }
  local expect act
  expect=$(awk '{print $1}' "$shafile")
  act=$(sha256sum "$path" | awk '{print $1}')
  [[ "$expect" == "$act" ]] || { echo "member SHA mismatch $deb: $act != $expect" >&2; return 1; }
}

merge_tree() {
  local src="$1" label="$2"
  local f rel dest
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    dest="$STAGE/$rel"
    if [[ -e "$dest" || -L "$dest" ]]; then
      if [[ -d "$f" && -d "$dest" ]]; then
        continue
      fi
      if ! cmp -s "$f" "$dest"; then
        echo "payload conflict from $label: $rel" >&2
        exit 1
      fi
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    cp -a "$f" "$dest"
  done < <(find "$src" \( -type f -o -type l \) -print0)
}

STAGE=$(mktemp -d)
EXTRACT=$(mktemp -d)
cleanup() { rm -rf "$STAGE" "$EXTRACT"; }
trap cleanup EXIT

mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/usr/share/doc/$PKG"
MEMBERS_TXT="$STAGE/usr/share/doc/$PKG/MEMBERS"
{
  echo "kemi-cli-toolkit $VER_DEB"
  echo "gork.bot协助开发"
  echo "members: gh ripgrep jq fd bat yq fzf delta zoxide hyperfine dust procs sd"
} >"$MEMBERS_TXT"

for row in "${MEMBERS[@]}"; do
  IFS='|' read -r name recipe deb script bin <<<"$row"
  path=""
  if ! path=$(find_member_deb "$recipe" "$deb"); then
    if [[ "${REBUILD_MISSING:-0}" == "1" ]]; then
      echo "rebuilding $name via $recipe/$script"
      bash "$REPO_ROOT/$recipe/$script"
      if ! path=$(find_member_deb "$recipe" "$deb"); then
        echo "still missing $deb after rebuild" >&2
        exit 1
      fi
    else
      echo "missing $deb" >&2
      echo "place it under $recipe/debs/ or set MEMBER_DEB_DIR, or rerun with REBUILD_MISSING=1" >&2
      exit 1
    fi
  fi
  [[ -n "$path" && -f "$path" ]] || { echo "still missing $deb" >&2; exit 1; }
  verify_member_sha "$recipe" "$deb" "$path"
  echo "merge $name <= $path"
  rm -rf "$EXTRACT"
  mkdir -p "$EXTRACT"
  dpkg-deb -x "$path" "$EXTRACT"
  merge_tree "$EXTRACT" "$name"
  [[ -x "$STAGE/usr/bin/$bin" ]] || { echo "member $name did not install /usr/bin/$bin" >&2; exit 1; }
  sha=$(sha256sum "$path" | awk '{print $1}')
  printf '%s\t%s\t%s\t/usr/bin/%s\n' "$name" "$deb" "$sha" "$bin" >>"$MEMBERS_TXT"
done

cat >"$STAGE/DEBIAN/control" <<EOT
Package: $PKG
Version: $VER_DEB
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Depends: libc6 (>= 2.31)
Provides: gh, rg, ripgrep, jq, fd, bat, yq, fzf, delta, git-delta, zoxide, hyperfine, dust, procs, sd
Conflicts: gh, rg, ripgrep, jq, fd, bat, yq, fzf, delta, git-delta, zoxide, hyperfine, dust, procs, sd, kemi-gh, kemi-ripgrep, kemi-jq, kemi-fd, kemi-bat, kemi-yq, kemi-fzf, kemi-delta, kemi-zoxide, kemi-hyperfine, kemi-dust, kemi-procs, kemi-sd
Replaces: gh, rg, ripgrep, jq, fd, bat, yq, fzf, delta, git-delta, zoxide, hyperfine, dust, procs, sd, kemi-gh, kemi-ripgrep, kemi-jq, kemi-fd, kemi-bat, kemi-yq, kemi-fzf, kemi-delta, kemi-zoxide, kemi-hyperfine, kemi-dust, kemi-procs, kemi-sd
Description: KEMI CLI toolkit for arm64 (Focal)
 Bundles gh, ripgrep (rg), jq, fd, bat, yq, fzf, delta, zoxide, hyperfine, dust, procs, and sd.
 Merged from the existing kemi-* arm64 debs. Installs those commands under /usr/bin.
 Supersedes mall apps 110-122. gork.bot协助开发.
EOT

mkdir -p "$OUT"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
rm -f "$DEB"
# Ubuntu 20.04 dpkg cannot unpack zstd debs; pin xz (focal default).
dpkg-deb -Zxz --root-owner-group --build "$STAGE" "$DEB"
if ! ar t "$DEB" | grep -q 'data.tar.xz'; then
  echo "expected data.tar.xz in $DEB" >&2
  exit 1
fi
sha256sum "$DEB" | tee "$DEB.sha256"
bytes=$(wc -c <"$DEB" | tr -d ' ')
act=$(sha256sum "$DEB" | awk '{print $1}')
echo "DEB=$DEB"
echo "bytes=$bytes"
echo "published pin $PUBLISHED_SHA ($PUBLISHED_BYTES bytes)"
if [[ -f "$PIN" ]]; then
  pin_act=$(awk '{print $1}' "$PIN")
  [[ "$pin_act" == "$PUBLISHED_SHA" ]] || { echo "committed pin drifted from published SHA" >&2; exit 1; }
fi
if [[ "$act" == "$PUBLISHED_SHA" && "$bytes" == "$PUBLISHED_BYTES" ]]; then
  echo "rebuild matches published mall artifact"
else
  echo "NOTE: local rebuild SHA/size differs from the published mall artifact."
  echo "      dpkg-deb is not bit-stable across toolchains. Do not replace the pin."
  echo "      CDN bytes stay at $PUBLISHED_SHA ($PUBLISHED_BYTES bytes)."
fi
echo "do not commit $DEB"
