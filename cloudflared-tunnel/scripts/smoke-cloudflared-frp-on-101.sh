#!/usr/bin/env bash
# Run on 101 after install. Short-lived; kills temp procs. Does NOT touch vibekits.
set -euo pipefail
EV=${1:-/root/t114-20261105}
mkdir -p "$EV"
exec > >(tee "$EV/smoke.log") 2>&1
echo "=== smoke $(date -Is) ==="
hostname; uname -m
echo "=== vibekits PIDs (must remain) ==="
ps -eo pid,stat,rss,args | awk '/[v]ibekits/ {print}' | tee "$EV/vibekits-pids-before.txt"
echo "=== cloudflared --version ==="
cloudflared --version | tee "$EV/cloudflared-version.txt"
echo "=== frpc/frps -v ==="
frpc -v | tee "$EV/frpc-version.txt"
frps -v | tee "$EV/frps-version.txt"

# frp loopback
cat > /tmp/t114-frps.toml << 'T'
bindPort = 17000
auth.method = "token"
auth.token = "t114-loopback-only"
T
cat > /tmp/t114-frpc.toml << 'T'
serverAddr = "127.0.0.1"
serverPort = 17000
auth.method = "token"
auth.token = "t114-loopback-only"
[[proxies]]
name = "loop"
type = "tcp"
localIP = "127.0.0.1"
localPort = 18081
remotePort = 18082
T
python3 -m http.server 18081 --bind 127.0.0.1 &
echo $! > /tmp/t114-http.pid
frps -c /tmp/t114-frps.toml &
echo $! > /tmp/t114-frps.pid
sleep 1
frpc -c /tmp/t114-frpc.toml &
echo $! > /tmp/t114-frpc.pid
sleep 2
code=$(curl -s -o /tmp/t114-curl.out -w '%{http_code}' http://127.0.0.1:18082/ || true)
echo "frp_loopback_http_code=$code" | tee "$EV/frp-loopback.txt"
kill $(cat /tmp/t114-frpc.pid) $(cat /tmp/t114-frps.pid) $(cat /tmp/t114-http.pid) 2>/dev/null || true
rm -f /tmp/t114-frpc.pid /tmp/t114-frps.pid /tmp/t114-http.pid /tmp/t114-frps.toml /tmp/t114-frpc.toml

# cloudflared quick tunnel
python3 -m http.server 18080 --bind 127.0.0.1 &
echo $! > /tmp/t114-http2.pid
rm -f /tmp/t114-cf.log
timeout 45 cloudflared tunnel --url http://127.0.0.1:18080 > /tmp/t114-cf.log 2>&1 &
echo $! > /tmp/t114-cf.pid
URL=""
for i in $(seq 1 30); do
  sleep 1
  URL=$(grep -oE 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' /tmp/t114-cf.log | head -1 || true)
  [ -n "$URL" ] && break
done
echo "quick_tunnel_url=$URL" | tee "$EV/cloudflared-quick.txt"
if [ -n "$URL" ]; then
  curl -sI --max-time 20 "$URL" | head -20 | tee "$EV/cloudflared-curl-I.txt" || echo CURL_FAIL >> "$EV/cloudflared-quick.txt"
else
  echo "QUICK_TUNNEL_NO_URL" | tee -a "$EV/cloudflared-quick.txt"
  tail -50 /tmp/t114-cf.log | tee "$EV/cloudflared-cf-log-tail.txt" || true
fi
kill $(cat /tmp/t114-cf.pid) $(cat /tmp/t114-http2.pid) 2>/dev/null || true
rm -f /tmp/t114-cf.pid /tmp/t114-http2.pid
cp /tmp/t114-cf.log "$EV/cloudflared-cf.log" 2>/dev/null || true

echo "=== vibekits PIDs after ==="
ps -eo pid,stat,rss,args | awk '/[v]ibekits/ {print}' | tee "$EV/vibekits-pids-after.txt"
echo SMOKE_DONE
