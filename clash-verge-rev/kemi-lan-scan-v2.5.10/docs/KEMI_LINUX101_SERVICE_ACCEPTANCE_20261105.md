# Clash Verge 2.5.10-1kemi2 在 Linux 101 的服务验收

设备为 Linux 101（ARM64）。已安装包为 clash-verge 2.5.10-1kemi2，发布制品 SHA-256 为 `9d70599c7f02f73cacbe205343ce9a812112040db5206f4408b2fb677eabe9c0`。客户端锁定 service IPC v2.7.7，提交 `3ed29700b093190b5e7addcaa892e77f172af544`。

- 启停：101 的主机 systemd 在私有网络和临时 `/run`、`/var/lib` 中运行包内服务程序。首轮只读 `/var/lib` 夹具导致启动失败。修正夹具后，`clash-verge-abi-systemd-isolated-1105-r2.service` 成功取得 owner lock 并建立 IPC socket。SIGTERM 后退出码为 0，socket 消失。
- 卸载：`clash-verge-uninstall-isolated-1105.service` 运行包内卸载程序，在私有挂载中删除合成单元、服务程序和核心目录，保留非目标状态文件。退出码为 0。隔离进程未连接主机 systemd 管理总线。
- 收尾：两个临时单元均回读为 not-found/inactive。隔离挂载已回收，无持久构建或安装副本。现有 Clash Verge GUI 和 Mihomo PID 337239、337385 均仍在运行。

正式主机服务注册与禁用、客户端授权握手、真实手机扫码仍待验收。
