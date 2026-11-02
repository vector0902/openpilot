#!/usr/bin/env bash
# run4_verify.sh — 验证模拟器链路：检查 onroad 进程 + 5 秒消息流计数 + UI 截图。
# 用法：先 ./run3_sim.sh，等约 30 秒后再 ./run4_verify.sh

set -uo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$REPO_DIR/.venv/bin:$PATH"

echo "== 1. onroad 核心进程 =="
ps aux | grep -E "selfdrive\.(modeld|controls\.controlsd|controls\.plannerd|selfdrived|car\.card|carrot\.radar|locationd\.locationd)" \
  | grep -v grep | awk '{for(i=11;i<=NF;i++) printf "%s ",$i; print ""}' | sort -u
echo

echo "== 2. 5 秒消息流计数 =="
python3 - <<'PY'
import time
from openpilot.cereal import messaging
sm = messaging.SubMaster(['modelV2','controlsState','carState'])
cnt={'modelV2':0,'controlsState':0,'carState':0}
t0=time.time()
while time.time()-t0 < 5:
    sm.update(100)
    for k in cnt:
        if sm.updated[k]: cnt[k]+=1
print(cnt)
PY

echo
echo "== 3. UI 截图（若 DISPLAY 有窗口管理器）=="
if command -v import >/dev/null; then
  import -window root /tmp/run4_ui.png 2>/dev/null \
    && echo "截图 -> /tmp/run4_ui.png" || echo "截图失败（可能 DISPLAY 无 GUI，不影响核心消息流）"
else
  echo "无 import 工具，跳过截图"
fi
