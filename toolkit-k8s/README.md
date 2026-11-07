# KEMI K8s 运维工具集

- package_name: `com.kemi.toolkit-k8s`
- deb Package: `kemi-toolkit-k8s`
- version: `1.0.0-1kemi1` / version_code `10000`
- app_id: 303
- scene: 已有集群时：切上下文、看资源、Helm/Kustomize、GitOps 交付、日志 tail。体积可控。
- members: 14 — k9s,kubectx,kubens,popeye,kubie,kubeseal,helm,kustomize,stern,krew,flux,helmfile,skaffold,devspace
- sha256: `4e07c0d390aae3072c213e20f13e43735527c62c5ddf16eeed0c4e9da7d5d34a`
- bytes: 174106540
- note: gork.bot协助开发

Build: `scripts/build.sh` (expects member debs via deb-map elsewhere; verify≠compile).
