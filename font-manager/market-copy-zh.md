# Font Manager

短描述：Font Manager 字体管理器（arm64）

长描述：Font Manager 0.7.7 — 图形字体管理器，用于预览、比较和管理桌面字体，无需手改配置或命令行。官方 Ubuntu 20.04（focal universe，focal-updates 无更新）arm64 当前正式包，并捆绑同源精确版本硬依赖 font-manager-common (= 0.7.7-0.3) 与 font-viewer (= 0.7.7-0.3)。官方无 Recommends。官方 Suggests（file-roller、nautilus-font-manager、nemo-font-manager、yelp）保持为建议，未捆绑。探针：aarch64，3 个独立 ELF（/usr/bin/font-manager、/usr/libexec/font-manager/font-viewer、libfontmanager.so.0.7.7），requiredGlibc 均为 2.17（3 个有版本需求、0 个空值），无 GLIBCXX（0 个有版本需求、3 个空值），满足 Ubuntu 20.04 / KEMI 101（glibc ≤2.31，GLIBCXX ≤3.4.28）。官方二进制保留在 /usr/bin/font-manager 与 /usr/libexec/font-manager/font-viewer，私有库在 /usr/lib/aarch64-linux-gnu/font-manager（RUNPATH 指向该目录）；/opt/font-manager 下仅为符号链接。桌面项、手册、官方 12 个 .mo（含 zh_CN）、官方 Yelp 帮助保留在标准路径。官方桌面图标为系统主题名 preferences-desktop-font；包装内无 hicolor 应用图标，未发明额外 SVG/PNG。官方帮助媒体中已有 48×48 PNG，仅用作商场 CREATE 图标，未另打一份进包。官方 D-Bus 服务已使用绝对路径并保留。官方 shlibs 已改指向 kemi-font-manager。本包提供版本化 Provides: font-manager (= 0.7.7-0.3)、font-manager-common (= 0.7.7-0.3)、font-viewer (= 0.7.7-0.3)。官方来源为 Ubuntu 20.04 focal universe font-manager 0.7.7-0.3（arm64）；官方 SHA 与大小已与 ports.ubuntu.com 池文件及 focal universe Packages stanza 核对一致。本轮无 librarian URL。

发布说明：首发 KEMI Linux：官方 Ubuntu 20.04 font-manager_0.7.7-0.3_arm64.deb 重打包为 kemi-font-manager，并捆绑同源精确版本 font-manager-common 与 font-viewer。合主线：gork.bot协助开发

合主线：gork.bot协助开发
