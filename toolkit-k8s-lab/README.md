# KEMI K8s 实验集群工具集

- package_name: `com.kemi.toolkit-k8s-lab`
- deb Package: `kemi-toolkit-k8s-lab`
- version: `1.0.0-1kemi1` / version_code `10000`
- app_id: 306
- scene: 本机起 kind/k3d/minikube/k0s、装 Cilium/Hubble、管 Talos、Argo CD。体积大，按需装。
- members: 8 — kind,k3d,minikube,k0s,talosctl,argocd,cilium-cli,hubble
- sha256: `84cf18b5e358a207bf6fbafdf831266a6455074751d8ed48b3ad42b0f0f59335`
- bytes: 363055896
- note: gork.bot协助开发

Build: `scripts/build.sh` (expects member debs via deb-map elsewhere; verify≠compile).
