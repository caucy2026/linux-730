# ollama (KEMI Linux)

Ollama local LLM runtime for KEMI mall (aarch64 CPU packaging).

| field | value |
|---|---|
| app_id | **308** |
| package_name | `com.kemi.ollama` |
| dpkg | `kemi-ollama` |
| version | `0.40.15-1kemi1` / code **4015** |
| bytes | 14441628 |
| sha256 | `b6e15712e04b42b6cb360128c5424730286f65211f6edfa818e6113166261e0d` |
| CDN | https://cdn.newlink-sz.com/kemiAppStore/linuxpkg/2026/11/1794108996674_d632c26c_kemi-ollama_0_40_15-1kemi1_arm64.deb |

Notes: official linux arm64 v0.40.15; CUDA bundles omitted for lean/101; glibc≤2.28 probe PASS; 101 smoke PASS (`ollama --version` → client 0.40.15; no model pull; package removed). Recipe-only; no `.deb` in git.

合主线：gork.bot协助开发
