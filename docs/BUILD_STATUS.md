# Build and optimization status

Session-Name: vibekits.linux开发
Session-ID: 01a04dde-32ea-7da2-8b77-2991c5e79baf

- Pristine Clash Verge Rev v2.5.2 source: complete tree backed up, tree hash `9242c84f7797d083c522e96b47bb65a5fd9be97c`.
- Pristine Collabora source pinned by KOffice142: complete tree backed up, tree hash `3979bebf85a0de73fb519bb4d53f5ad29bfb34a2` (81035 tracked blobs). Private KEMI product sources are excluded.
- Clash source build: pending; the existing installed compatibility package is derived from an official prebuilt release and is not claimed as a source build. Its official source already enables Tokio's multi-thread runtime. Keep its standard release optimization; do not substitute the unoptimized fast-release profile as a production optimization.
- KOffice source build: pending; canonical KEMI patch replay is prepared separately. A private ARM64 Ubuntu26 build environment is being provisioned for the project's Qt6/C++20 requirements, without replacing the Ubuntu20 host libraries.
- KEMI Send ARM64 165: complete Rust and GUI Release passed. Rust stage 2171.056819s (one rustc maximum), GUI 260.563666s (Ninja j8, eight C++ compiler processes observed). This is compile evidence only. A source-pinned Linux secure-storage no-prompt revision is being rebuilt before actual launch acceptance. Private Send source is not copied into this public repository.

Runtime optimization and package publication remain unverified. No marketplace success or stable-runtime claim is made by this source backup. Exact accepted patches, build recipes and measurements must be added with the corresponding final artifact identity after validation.
