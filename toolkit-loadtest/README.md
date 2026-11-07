# KEMI 压测工具集

- package_name: `com.kemi.toolkit-loadtest`
- deb Package: `kemi-toolkit-loadtest`
- version: `1.0.0-1kemi1` / version_code `10000`
- app_id: 298
- scene: 发版前打 HTTP/gRPC 压测，看 QPS/延迟。不含资产侦察。
- members: 7 — k6,ghz,fortio,vegeta,bombardier,cassowary,oha
- sha256: `1941681532ef37bf0ee295cd1ad7461264097a5564aac547c4e3d1ade6cdf95e`
- bytes: 47915296
- note: gork.bot协助开发

Build: `scripts/build.sh` (expects member debs via deb-map elsewhere; verify≠compile).
