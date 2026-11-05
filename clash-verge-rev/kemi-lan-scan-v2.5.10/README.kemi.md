# KEMI backup of Clash Verge Rev v2.5.10

This directory is a source backup. It is not an installable build, and it does not publish anything to an app market.

## Upstream pin

- Project: [clash-verge-rev](https://github.com/clash-verge-rev/clash-verge-rev)
- Tag: `v2.5.10`
- Commit: `c83f7ad529c7c9cb3d2d54a0955ef8c1b22a411b`

The original `LICENSE` (GPL-3.0-only) and upstream notices stay in this tree. Upstream `README.md` is unchanged.

## KEMI delta

Applied `clash-v2.5.10-scan-20261104.patch` on that pin. On Linux, the profile URL field can open a three-minute LAN QR page. A phone on the same network scans it, submits an `http` or `https` subscription address, and the desktop field is backfilled. The user still reviews the address and clicks Import. The page is not written to disk, and the listener stops when the dialog closes or the code expires.

Touched paths include:

- `src-tauri/src/utils/lan_profile_input.rs`
- `src-tauri/src/utils/lan-input-en.html`
- `src-tauri/src/utils/lan-input-zh.html`
- `src/components/profile/lan-input-dialog.tsx`
- `src/services/profile-lan-input.ts`
- `src-tauri/src/cmd/network.rs`
- `src-tauri/src/ipc.rs`
- `src/pages/profiles.tsx`
- `src/components/profile/profile-viewer.tsx`
- English, Simplified Chinese, and Traditional Chinese profile locales

## What this tree is not

Release binaries, `node_modules`, `.tools` caches, and `target/` build output are not part of this backup. No Git LFS payloads were added. Marketplace publication is a separate step and is not claimed here.

gork.bot协助开发
