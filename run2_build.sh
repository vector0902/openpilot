#!/usr/bin/env bash
# run2_build.sh — SCons 构建（生成 cereal/gen、*.so、loggerd/camerad/encoderd 等 native 二进制）。
# 前置：run1_prepare.sh 完成（.venv 就绪）。完成后进入 run3_sim.sh。
# 用法：./run2_build.sh

set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -x "$REPO_DIR/.venv/bin/scons" ]; then
  echo "缺少 $REPO_DIR/.venv，请先执行 ./run1_prepare.sh" >&2
  exit 1
fi

# 需要把 .venv/bin 放进 PATH（capnpc / capnpc-c++ 等工具来自 capnproto wheel）
export PATH="$REPO_DIR/.venv/bin:$PATH"
cd "$REPO_DIR"

JOBS="${JOBS:-16}"
echo "开始 SCons 构建（-j $JOBS）；完整日志见 /tmp/run2_scons.log"
"$REPO_DIR/.venv/bin/scons" -j "$JOBS" 2>&1 | tee /tmp/run2_scons.log

if [ -x "$REPO_DIR/openpilot/system/loggerd/loggerd" ]; then
  echo ""
  echo "run2 完成（loggerd 已生成）。下一步：./run3_sim.sh"
else
  echo "ERROR: 构建后仍未找到 openpilot/system/loggerd/loggerd" >&2
  exit 1
fi
