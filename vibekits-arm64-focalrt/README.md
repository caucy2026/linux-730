# VibeKits Linux arm64 focalrt runtime bundle

合主线注明「gork.bot协助开发」。**验证 ≠ 编译**。禁止杀真机 vibekits。

## Why
773 arm64 ELF needs `GLIBCXX_3.4.29` / `CXXABI_1.3.13`. Ubuntu 20.04 (101) system
`libstdc++6` tops out at `GLIBCXX_3.4.28`. Official Jammy `libstdc++6` needs GLIBC ≥ 2.32,
so it cannot be dropped onto Focal (glibc 2.31).

## Fix
Bundle conda-forge linux-aarch64:
- `libstdcxx-ng` 12.2.0 (`hc13a102_19`) → `libstdc++.so.6.0.30` (GLIBC_2.17 only)
- `libgcc-ng` 12.2.0 (`h607ecd0_19`) → `libgcc_s.so.1`

Place under `/opt/vibekits/lib/` (ELF already has `RUNPATH=$ORIGIN/lib`). Wrapper
`/opt/vibekits/vibekits` exports `LD_LIBRARY_PATH` then execs `vibekits.real`.
Control Depends softened to `libstdc++6 (>= 9)`.

## Artifact (this turn)
- `VibeKits-1.9.0-dev.773-linux-arm64-focalrt.deb`
- sha256 `5fe2cfd5d030398c70951164e57114ebab9d6d5c46a100b0ab46fa76c2c239dc`
- bytes `167302684`
- version kept `1.9.0~dev.773+2773` / code **2773**
- FREEZE src `a580359bd06cd295daf874b114d0b41f081b6d4e`

## 101 smoke
PASS is a premise of this note (bypass extract; prod 772 untouched). See work-notes under t84.
Target is a side-path smoke on 101 Ubuntu 20.04. This directory stores the repack script and notes only; do not commit the `.deb`.

## Mall package
Planned independent `package_name`: `com.caucy.vibekits.arm64`.
Do not overwrite app90 `com.caucy.vibekits`.
