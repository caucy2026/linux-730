# KEMI 供应链 IaC 工具集

- package_name: `com.kemi.toolkit-supply`
- deb Package: `kemi-toolkit-supply`
- version: `1.0.0-1kemi1` / version_code `10000`
- app_id: 305
- scene: 制品签名/SBOM/漏洞扫、OpenTofu/Terragrunt、Cue/Buf/Dagger、云成本估算、gRPC 调试。
- members: 12 — cosign,syft,grype,trivy,tofu,terragrunt,cue,buf,dagger,infracost,grpcurl,evans
- sha256: `941eee13bb13d25eea5e8470e02d62b54e12e018c18b31a3a5ff5ec1d823be97`
- bytes: 214915800
- note: gork.bot协助开发

Build: `scripts/build.sh` (expects member debs via deb-map elsewhere; verify≠compile).
