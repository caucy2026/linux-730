# anythingllm (KEMI Linux)

合主线：**gork.bot协助开发**。验证 ≠ 编译。

| 项 | 值 |
|---|---|
| package_name | `com.kemi.anythingllm` |
| dpkg | `kemi-anythingllm` |
| version | `1.19.0-1kemi1` / version_code `11900` |
| upstream | Mintplex Labs AnythingLLM Desktop **1.19.0** Arm64 AppImage |
| install | `/opt/kemi-anythingllm/AnythingLLMDesktop-Arm64.AppImage` + `/usr/bin/anythingllm` |
| runtime | AppImage（`APPIMAGE_EXTRACT_AND_RUN=1`）；Depends libc6 ≥ 2.31 |
| category | 工作 |
| app_id | **128** |
| SHA256 | `9ee0277d5c3dd3364bd20715c8f360fce305e116fc957f72cd64fe663a534e29` |
| size | 628456744 B |
| CDN | `https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1793975126593_90c3733a_kemi-anythingllm_1_19_0-1kemi1_arm64.deb` |
| CREATE | **DONE**（t139 2026-11-06 Asia/Shanghai）四层 L1–L4 PASS |
| 101 smoke | **SKIP**（云机 docker 数据丢失后控制器 ID 换成 `6952337164`，连 101 得 `consent_pending`；CREATE 已成功仍算商场 DONE。101 UI 同意该控制器后可补：CDN curl + `dpkg -i` + `anythingllm --help` / AppImage `--appimage-help`） |

## 边界

- 桌面 RAG/文档 AI；需用户自备 LLM key；冒烟不塞 key。
- ~600MiB AppImage；101 根盘须有 ≥2GiB 余量再装。
- 无 Docker；launcher 设 `APPIMAGE_EXTRACT_AND_RUN=1`。

## 构建

箱侧打包：AppImage → deb 包装（`/opt/kemi-anythingllm` + `/usr/bin/anythingllm`）。勿把 appstore token 写入本树。勿 git push（由合主线另开，注明 gork.bot协助开发）。
