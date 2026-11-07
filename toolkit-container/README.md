# KEMI 容器镜像工具集

- package_name: `com.kemi.toolkit-container`
- deb Package: `kemi-toolkit-container`
- version: `1.0.0-1kemi1` / version_code `10000`
- app_id: 297
- scene: 本机容器排障与镜像仓库：TUI 管容器、看层、nerdctl/crane/oras 推拉 OCI。不含 K8s。
- members: 10 — lazydocker,dive,nerdctl,ctop,dry,oxker,crane,oras,regctl,pack
- sha256: `e18db89a386139bb2609688cfb33b5233a27eda9b96dd084ca8af637824d6b78`
- bytes: 37479104
- note: gork.bot协助开发

Build: `scripts/build.sh` (expects member debs via deb-map elsewhere; verify≠compile).
