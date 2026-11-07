# KEMI 开发 Git 工具集

- package_name: `com.kemi.toolkit-dev`
- deb Package: `kemi-toolkit-dev`
- version: `1.0.0-1kemi1` / version_code `10000`
- app_id: 299
- scene: 写代码与发版：交互式 git、语义 diff、发版笔记、CI/脚本/Go 静态检查、Dockerfile lint。
- members: 15 — lazygit,gitui,git-cliff,difftastic,riff,tokei,typos,ast-grep,goreleaser,actionlint,shellcheck,shfmt,gofumpt,golangci-lint,hadolint
- sha256: `b35f42a2a4ad62f164ce214efc2746fc565dea392cd2606cfbafbb128af6e8f7`
- bytes: 76132500
- note: gork.bot协助开发

Build: `scripts/build.sh` (expects member debs via deb-map elsewhere; verify≠compile).
