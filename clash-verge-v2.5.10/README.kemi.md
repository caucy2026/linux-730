# KEMI backup of Clash Verge Rev v2.5.10

This directory is a source backup. It is not an installable build, and it does not publish anything to an app market.

## Upstream pin

- Project: [clash-verge-rev](https://github.com/clash-verge-rev/clash-verge-rev)
- Tag: `v2.5.10`
- Commit: `c83f7ad529c7c9cb3d2d54a0955ef8c1b22a411b`

The original `LICENSE` (GPL-3.0-only) and upstream notices stay in this tree. Upstream `README.md` is unchanged.

## KEMI delta

KEMI adds a LAN scan backfill for profile import:

- The Profiles page can open a short-lived page on the LAN.
- A phone on the same network scans the code, opens `lan-input-en.html` or `lan-input-zh.html`, and submits a subscription URL with the pairing code.
- The desktop field is backfilled from that submission. The URL is kept in memory only while the dialog is open.

New and changed paths:

- `src-tauri/src/utils/lan_profile_input.rs`
- `lan-input-en.html`
- `lan-input-zh.html`
- `src/components/profile/lan-input-dialog.tsx`
- `src/services/profile-lan-input.ts`
- `src-tauri/src/cmd/network.rs`
- `src-tauri/src/ipc.rs`
- `src/pages/profiles.tsx`
- profile locale files

`clash-v2.5.10-scan-20261104.patch` was not present on disk when this tree was assembled, so this delta was reconstructed onto the pinned upstream sources at those paths.

## What this tree is not

Release binaries, `node_modules`, `.tools` caches, and `target/` build output are not part of this backup. Marketplace publication is a separate step and is not claimed here.

gork.bot协助开发
