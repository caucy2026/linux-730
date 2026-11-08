#!/usr/bin/env bash
# Wrap official Ollama linux arm64 (CPU libs; CUDA bundles omitted for 101/lean) as kemi-ollama.
# Upstream: ollama-linux-arm64.tar.zst v0.40.15 — gork.bot协助开发 · Verify ≠ compile
set -euo pipefail
ROOT=/workspace/t140-20261108-ollama
VER_UP=0.40.15
VER_DEB="${VER_UP}-1kemi1"
ARCH=arm64
PKG=kemi-ollama
DL="${DL:-$ROOT/dl}"
OUT="${OUT:-$ROOT/debs}"
EXTRACT="${EXTRACT:-$DL/extract-cpu}"
mkdir -p "$DL" "$OUT"
test -x "$EXTRACT/bin/ollama"
test -d "$EXTRACT/lib/ollama"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/pkg/DEBIAN" \
  "$STAGE/pkg/usr/bin" \
  "$STAGE/pkg/usr/lib" \
  "$STAGE/pkg/usr/share/doc/$PKG" \
  "$STAGE/pkg/usr/share/applications" \
  "$STAGE/pkg/usr/lib/systemd/user"
# Official layout: extract to /usr → bin/ollama + lib/ollama
cp -a "$EXTRACT/bin/ollama" "$STAGE/pkg/usr/bin/ollama"
chmod 0755 "$STAGE/pkg/usr/bin/ollama"
cp -a "$EXTRACT/lib/ollama" "$STAGE/pkg/usr/lib/"
ln -sf ollama "$STAGE/pkg/usr/bin/kemi-ollama"
cat > "$STAGE/pkg/usr/share/applications/ollama.desktop" << 'EOT'
[Desktop Entry]
Name=Ollama
Comment=Run large language models locally
Exec=ollama
Terminal=true
Type=Application
Categories=Development;Science;
Keywords=llm;ai;local;
EOT
cat > "$STAGE/pkg/usr/lib/systemd/user/ollama.service" << 'EOT'
[Unit]
Description=Ollama Service (user)
After=network-online.target

[Service]
ExecStart=/usr/bin/ollama serve
Restart=on-failure
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=default.target
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/copyright" << EOT
Upstream: https://github.com/ollama/ollama
License: MIT (see upstream GO_LICENSE / LLAMA_CPP_LICENSE under /usr/lib/ollama/)
Official linux arm64 v${VER_UP} (CPU runners; NVIDIA CUDA bundles omitted for lean/101).
合主线：gork.bot协助开发
EOT
cat > "$STAGE/pkg/usr/share/doc/$PKG/README.kemi.md" << EOT
# ${PKG}
Ollama ${VER_UP} (official linux arm64, CPU-only packaging).

Installs:
- /usr/bin/ollama
- /usr/lib/ollama/ (ggml CPU runners + llama libs; no cuda_v12/cuda_v13)

Start: \`ollama serve\` then \`ollama --version\` / \`ollama run <model>\`.
Do not pull large models on disk-constrained devices without free space.

合主线：gork.bot协助开发
EOT
INSTALLED_SIZE=$(du -sk "$STAGE/pkg" | awk '{print $1}')
cat > "$STAGE/pkg/DEBIAN/control" << EOT
Package: $PKG
Version: $VER_DEB
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.28)
Maintainer: KEMI / gork.bot <noreply@kemi.local>
Homepage: https://ollama.com
Description: Ollama local LLM runtime (arm64 CPU)
 Ollama ${VER_UP} — run LLMs locally. Official arm64 binary + CPU libs.
 NVIDIA CUDA bundles omitted (lean; fits glibc 2.31 / Ubuntu 20.04).
 MIT. gork.bot协助开发.
EOT
cat > "$STAGE/pkg/DEBIAN/postinst" << 'EOT'
#!/bin/sh
set -e
# ensure libs discoverable (ollama looks under /usr/lib/ollama by default)
exit 0
EOT
chmod 0755 "$STAGE/pkg/DEBIAN/postinst"
DEB="$OUT/${PKG}_${VER_DEB}_${ARCH}.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE/pkg" "$DEB"
sha256sum "$DEB" | tee "$DEB.sha256"
ls -la "$DEB"
stat -c%s "$DEB"
