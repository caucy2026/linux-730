# Linux 730 source and reproducible-build backups

This repository preserves third-party original source separately from Linux adaptations, build recipes and measured acceptance results.

## Current source inputs

- Clash Verge Rev v2.5.2: upstream commit `28f2efc504059b1dc75c793618b775c8e1b2a5f1`, GPL-3.0-only. The complete original tracked tree is under `clash-verge-rev/original/v2.5.2/`; retain its original LICENSE and notices.
- KOffice underlying Collabora Online source: pinned `b91cb7428e620f5c34c2ff94d7f8ce2a7d494c62`; complete original tracked tree is preserved under `collabora-online/original/` and verified against the upstream tree hash. KEMI-specific private product repositories are not copied here.

## Backup layout

Use one root directory per project. Store original sources, adaptations and manifests inside their owning project directory. Keep separate original versions in versioned subdirectories of that project. Do not place project source at the repository root. Keep upstream source trees byte-for-byte intact, with their licenses and notices. Put Linux adaptations and verification evidence outside those original source trees.

Clash Verge Rev v2.5.9 and v2.5.10 are backed up under `clash-verge-rev/original/v2.5.9/` and `clash-verge-rev/original/v2.5.10/`. Their existing archival branches retain upstream history and commit IDs. The separate KEMI adaptation is under `clash-verge-rev/kemi-lan-scan-v2.5.10/`. Source manifests are stored alongside each project.

## Verification status

Source preservation is not a successful build or an optimized release. The currently tested Clash installation came from an official prebuilt package plus a private compatibility runtime; it is **not** claimed as our source build. Source compilation, full acceptance and KEMI market publication remain pending. Optimized source changes and exact measured results will be recorded separately.

## Parallel execution policy

Use all eight CPU cores where the workload supports it and memory measurements permit it. Record actual Cargo/C++/worker concurrency, wall time, peak memory, CPU and UI response. Keep the GUI responsive by moving appropriate CPU work to bounded workers. A fixed j8 is not a license to exceed available memory, and a serial stage must never be reported as j8.

No credentials, user configuration, subscriptions, private chats or generated build caches belong in this repository. Upstream workflows remain inert inside the source subtree; this backup does not enable automatic CI.