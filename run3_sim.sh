#!/usr/bin/env bash
# run3_sim.sh — 启动 MetaDrive 模拟器：manager（模拟模式） + bridge（虚拟车辆/CAN/相机/IMU）。
# 前置：run2_build.sh 完成。可选 DISPLAY（UI 渲染；无头可跳过，用 xvfb-run）。
# 用法：./run3_sim.sh   结束后：./run4_verify.sh 验证；./run5_stop.sh 停止。

set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$REPO_DIR/.venv/bin:$PATH"

# UI 需要的显示；无头可设 DISPLAY 到 xvfb 或留空（不影响核心消息流）
export DISPLAY="${DISPLAY:-:0}"

if [ ! -f "$REPO_DIR/openpilot/tools/sim/lib/simulated_sensors.py" ]; then
  echo "ERROR: 找不到模拟器文件，请先完成 run1/run2" >&2
  exit 1
fi

# 幂等：若已在跑就提示，避免重复起（用 tmux 会话名管理）
if tmux has-session -t opsim_m 2>/dev/null || tmux has-session -t opsim_b 2>/dev/null; then
  echo "模拟器已在运行（tmux 会话 opsim_m / opsim_b）。要停止请先 ./run5_stop.sh。"
  exit 0
fi

echo "启动 manager（模拟模式）..."
tmux new-session -d -s opsim_m -x 200 -y 50 \
  "cd $REPO_DIR && export DISPLAY=${DISPLAY} && source .venv/bin/activate && ./openpilot/tools/sim/launch_openpilot.sh 2>&1"

echo "启动 MetaDrive bridge..."
tmux new-session -d -s opsim_b -x 200 -y 50 \
  "cd $REPO_DIR && export DISPLAY=${DISPLAY} && source .venv/bin/activate && python3 openpilot/tools/sim/run_bridge.py 2>&1"

echo "已启动。manager=tmux opsim_m，bridge=tmux opsim_b。"
echo "验证：./run4_verify.sh    停止：./run5_stop.sh"
