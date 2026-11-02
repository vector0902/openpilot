#!/usr/bin/env bash
# run5_stop.sh — 停止 run3_sim.sh 启动的 manager + bridge（tmux 会话 opsim_m / opsim_b）。
# 用法：./run5_stop.sh

set -uo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

stopped=0
for s in opsim_m opsim_b; do
  if tmux has-session -t "$s" 2>/dev/null; then
    tmux kill-session -t "$s" 2>/dev/null
    echo "已停止 tmux 会话 $s"
    stopped=1
  fi
done

if [ "$stopped" -eq 0 ]; then
  echo "没有检测到运行中的模拟器 tmux 会话（opsim_m / opsim_b）。"
fi
