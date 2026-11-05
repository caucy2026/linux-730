#!/bin/bash
set -u
export PATH=/opt/openclaw/bin:/opt/openclaw-node/bin:$PATH
export OMP_NUM_THREADS=3
export npm_config_prefix=/opt/openclaw

# stop leftover installs (do NOT touch vibekits)
pkill -f 'npm install openclaw' 2>/dev/null || true
pkill -f '101-npm-openclaw.sh' 2>/dev/null || true
sleep 1

echo '=== VERSIONS ==='
which node; node -v
which npm; npm -v
which openclaw; openclaw --version || /opt/openclaw/bin/openclaw --version

# allow blocked postinstalls once (esbuild etc.) — short bounded
echo '=== ALLOW SCRIPTS REPAIR ==='
npm install -g --allow-scripts=@google/genai,esbuild,protobufjs openclaw@latest 2>&1 | tee /opt/openclaw/npm-allow-scripts.log | tail -30

echo '=== GATEWAY HELP ==='
openclaw gateway --help 2>&1 | head -100

echo '=== DOCTOR ==='
openclaw doctor 2>&1 | head -80 || true

echo '=== GATEWAY STATUS ==='
openclaw gateway status 2>&1 | head -40 || true

echo '=== HELP TOP ==='
openclaw --help 2>&1 | head -40 || true

# vibekits still alive
echo '=== VIBEKITS ==='
pgrep -a vibekits | head -5 || true

echo SMOKE_SCRIPT_DONE
