# 101 OpenClaw 移植摸底（t79 · 2026-11-04 Asia/Shanghai）

合主线：gork.bot协助开发。验证≠编译。

## 目标
- hostname: `mp730-156`
- routingId: `7634801763`
- arch: `aarch64`
- OS: Ubuntu 20.04.5 LTS (Focal)
- kernel: `5.10.43_wudangstick`
- glibc: **2.31**
- RAM: ≈5.5Gi · **SwapTotal=0**
- disk `/`: 95G · 可用 ≈19G（80% used）
- Vibekits（禁止误杀）: PID 47931 `/opt/vibekits/vibekits` + relay 48080

## 基线软件（摸底时）
- Node: **无**
- npm: **无**
- openclaw: **无**
- 出网: `nodejs.org` / `registry.npmjs.org` HTTP/2 200

## 拟装口径（已备料，未完成投递）
- Node: **v26.13.0** linux-arm64 官方 tarball（≥26.12.1）
  - 箱内: `/workspace/t79-20261104/versions/node-v26.13.0-linux-arm64.tar.xz`
  - SHA256: `406fe3fbde1c054adff8b297c16fdb5af6659db327c1ac8acd46b56ef1af9a92`
  - 已 `docker cp` 进控制器 `vk-u20-amd64-772-run:/tmp/…`
- OpenClaw npm latest 当时: **2026.10.10**
- 安装前缀: `/opt/openclaw-node` + `/opt/openclaw`（独立于 vibekits）
- 线程: `OMP_NUM_THREADS=3`，npm jobs≤2
- **不做** Linux amd64-only desktop companion `.deb`

## 仿针时间线（Asia/Shanghai）
| 时刻 | 事件 |
|---|---|
| 17:29 | §6.8：虚报 registered + ESTAB=0 → heal-relay；同 RID `9245390203` / digest 未变；`request_pk` 到 A |
| 17:30:20 | **1× connect（箱控制器）PASS**：hostname=mp730-156 · sshReady · actualTransport=relay |
| 17:31 | profile PASS；上传 `101-profile.sh` |
| 17:32 | 长 `ssh_exec` 安装 → `kex_exchange_identification: Connection closed`；protocol connections=[] |
| 17:33 | disconnect 清理后，箱 **connect2** → `remote_disabled`（managed Harness access is disabled） |
| 17:35 | 控制机 newlink `1554650784` connect → 同 `remote_disabled` |
| 17:36 | peer_presence：**online=true**（serverReplyVerified）；冷却后再 connect 仍 `remote_disabled` |

## 阻塞
目标 101 **仿真/managed Harness 门禁关闭**（易失 `SIMULATOR_ACCESS_ENABLED`）。设备仍在线，但禁止继续盲连。

需要用户在 **101 Vibekits UI** 重新打开「允许仿真/Harness」，或**明确授权**后重启**目标** Vibekits（本回合未杀、未授权不杀）。恢复后可立刻：upload Node tar → extract → `npm i -g openclaw@latest` → CLI/gateway 冒烟。

## 续装结果（用户打开仿真后 · Asia/Shanghai 17:49–18:05）

- 箱控制器 heal → 1× connect PASS（relay）
- Node 26.13.0 解压至 `/opt/openclaw-node`（SHA 核过）
- `npm i -g openclaw@latest --allow-scripts=openclaw`（prefix `/opt/openclaw`）→ **2026.10.10 (7dc3350)**
- 符号链接：`/usr/local/bin/{node,npm,npx,openclaw}`
- Gateway 冒烟监听 **18789** 后已停止
- disconnect 收尾；未上架；未杀 vibekits
