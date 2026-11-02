#!/usr/bin/env bash
# run.sh — 一键：前置(venv+依赖) → 构建 → 起模拟器 → 验证。等价于依次执行 run1..run4，
# 最后保持模拟器运行（停止请用 ./run5_stop.sh）。
# 用法：./run.sh
# 说明：每段都可单独抽出（run1_prepare / run2_build / run3_sim / run4_verify）单独跑。

set -uo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "=== [1/4] 前置：venv + 依赖 ==="
bash ./run1_prepare.sh

echo "=== [2/4] SCons 构建 ==="
bash ./run2_build.sh

echo "=== [3/4] 启动模拟器（manager + bridge） ==="
bash ./run3_sim.sh

echo "=== [4/4] 验证 ==="
echo "等待 30 秒让 onroad 进程起来..."
sleep 30
bash ./run4_verify.sh

echo ""
echo "完成。模拟器保持运行中；验证/查看：./run4_verify.sh；停止：./run5_stop.sh"
