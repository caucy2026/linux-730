#!/usr/bin/env python3
import json,urllib.request,pathlib,sys,time,os
RID="7634801763"
CDN=os.environ["ALLM_CDN"]
EXPECT=os.environ.get("ALLM_SHA","9ee0277d5c3dd3364bd20715c8f360fce305e116fc957f72cd64fe663a534e29")
EXPECT_BYTES=int(os.environ.get("ALLM_BYTES","628456744"))
REMOTE="/tmp/kemi-anythingllm_1.19.0-1kemi1_arm64.deb"
OUT="/tmp/t139-allm-cdn-smoke.json"
results={}

def load():
  b=json.load(open("/vk/home-live/VibekitsData/Mcp/tool-bridge.json")); return b["endpoint"].rstrip("/"), b["token"]
def inv(tid,args=None,timeout=300):
  ep,tok=load(); last=None
  for attempt in range(8):
    req=urllib.request.Request(ep+"/invoke",data=json.dumps({"toolId":tid,"arguments":args or {}}).encode(),
      headers={"Content-Type":"application/json","Authorization":"Bearer "+tok},method="POST")
    try:
      with urllib.request.urlopen(req,timeout=timeout) as r: last=json.loads(r.read().decode())
    except Exception as e:
      last={"ok":False,"error":"%s:%s"%(type(e).__name__,str(e)[:200])}; time.sleep(2); continue
    err=str(last.get("error") or "")+str(last.get("code") or "")
    if "ssh_command_busy" in err:
      time.sleep(4); continue
    return last
  return last
def connected(r):
  return bool(r and r.get("ok") and (r.get("data") or {}).get("connected"))

try: inv("vibekits.simulator.disconnect",{"routingId":RID},timeout=45)
except Exception: pass
r=inv("vibekits.simulator.connect",{"routingId":RID},timeout=120)
results["connect_ok"]=r.get("ok"); results["host"]=((r.get("data") or {}).get("hostname"))
results["connect_err"]=(r.get("error") or r.get("code") or "")[:200]
print("connect", results["connect_ok"], results["host"], results["connect_err"], flush=True)
if not connected(r):
  pathlib.Path(OUT).write_text(json.dumps(results,ensure_ascii=False,indent=2)); print("RESULT=FAIL_CONNECT"); sys.exit(1)

pre=inv("vibekits.simulator.ssh_exec",{"routingId":RID,"command":"echo VK_PIDS=$(pgrep -d, -x vibekits || pgrep -d, vibekits | head -c 200 || true); df -hT / | tail -1; python3 -c \"import os;st=os.statvfs('/');a=st.f_bavail*st.f_frsize;print('AVAIL',a);print('DISK_OK' if a>2*1024**3 else 'DISK_STOP')\""},timeout=90)
stdout=((pre.get("data") or {}).get("stdout") or "")
results["pre"]=stdout[:800]
print("PRE", stdout[:500], flush=True)
if "DISK_STOP" in stdout:
  inv("vibekits.simulator.disconnect",{"routingId":RID},timeout=45)
  pathlib.Path(OUT).write_text(json.dumps(results,ensure_ascii=False,indent=2)); print("RESULT=STOP_DISK"); sys.exit(2)

cmd=("set -e\n"
 "rm -f /tmp/kemi-anythingllm*.deb 2>/dev/null || true\n"
 "rm -rf /tmp/.mount_Anythi* /tmp/appimage* 2>/dev/null || true\n"
 f"curl -fL --connect-timeout 30 --max-time 1800 -o {REMOTE} '{CDN}'\n"
 f"test \"$(stat -c%s {REMOTE})\" = \"{EXPECT_BYTES}\"\n"
 f"test \"$(sha256sum {REMOTE} | awk '{{print $1}}')\" = \"{EXPECT}\"\n"
 "VK_BEFORE=$(pgrep -d, vibekits || true); echo VK_BEFORE=$VK_BEFORE\n"
 f"dpkg -i {REMOTE}\n"
 "test -x /usr/bin/anythingllm\n"
 "test -x /opt/kemi-anythingllm/AnythingLLMDesktop-Arm64.AppImage\n"
 "HELP=$(APPIMAGE_EXTRACT_AND_RUN=1 /opt/kemi-anythingllm/AnythingLLMDesktop-Arm64.AppImage --appimage-help 2>&1 | head -c 2000 || true); echo HELP_HEAD=\"$HELP\"\n"
 "echo \"$HELP\" | grep -qiE 'AppImage|Usage|Options|appimage|--appimage'\n"
 "VK_AFTER=$(pgrep -d, vibekits || true); echo VK_AFTER=$VK_AFTER\n"
 "test \"$VK_BEFORE\" = \"$VK_AFTER\"; echo SMOKE_PASS\n"
 f"rm -f {REMOTE}\n"
 "df -hT / | tail -1\n")
smoke=inv("vibekits.simulator.ssh_exec",{"routingId":RID,"command":cmd},timeout=2400)
results["smoke_ok"]=smoke.get("ok")
results["smoke_stdout"]=((smoke.get("data") or {}).get("stdout") or "")[:6000]
results["smoke_stderr"]=((smoke.get("data") or {}).get("stderr") or "")[:2000]
results["smoke_err"]=(smoke.get("error") or smoke.get("code") or "")[:300]
print("SMOKE", results["smoke_ok"], results["smoke_stdout"][:2000], flush=True)
inv("vibekits.simulator.disconnect",{"routingId":RID},timeout=45)
pathlib.Path(OUT).write_text(json.dumps(results,ensure_ascii=False,indent=2))
if "SMOKE_PASS" in results["smoke_stdout"]:
  print("RESULT=PASS"); sys.exit(0)
print("RESULT=FAIL"); sys.exit(1)
