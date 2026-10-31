# Linux 730 source and reproducible-build backups

This repository preserves third-party original source separately from Linux adaptations, build recipes and measured acceptance results.

## Current source inputs

- Clash Verge Rev v2.5.2: upstream commit `28f2efc504059b1dc75c793618b775c8e1b2a5f1`, GPL-3.0-only. The complete original tracked tree is under `upstream/clash-verge-rev/`; retain its original LICENSE and notices.
- KOffice underlying Collabora Online source: pinned `b91cb7428e620f5c34c2ff94d7f8ce2a7d494c62`; original-source backup is being prepared. KEMI-specific private product repositories are not copied here.

## Verification status

Source preservation is not a successful build or an optimized release. The currently tested Clash installation came from an official prebuilt package plus a private compatibility runtime; it is **not** claimed as our source build. Source compilation, full acceptance and KEMI market publication remain pending. Optimized source changes and exact measured results will be recorded separately.

## Parallel execution policy

Use all eight CPU cores where the workload supports it and memory measurements permit it. Record actual Cargo/C++/worker concurrency, wall time, peak memory, CPU and UI response. Keep the GUI responsive by moving appropriate CPU work to bounded workers. A fixed j8 is not a license to exceed available memory, and a serial stage must never be reported as j8.

No credentials, user configuration, subscriptions, private chats or generated build caches belong in this repository. Upstream workflows remain inert inside the source subtree; this backup does not enable automatic CI.
