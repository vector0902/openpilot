#!/usr/bin/env bash
# run1_prepare.sh — 前置：克隆仓库 + 创建 Python 3.12 venv + 安装依赖（含测试/模拟器 extras）。
# 幂等：可重复执行。完成后进入 run2_build.sh。
# 用法：在仓库内任意目录执行 ./run1_prepare.sh，或从外层目录 ./openpilot/run1_prepare.sh

set -euo pipefail

# 定位仓库根目录（含 pyproject.toml 与 launch_openpilot.sh）
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$REPO_DIR/pyproject.toml" ] || [ ! -f "$REPO_DIR/launch_openpilot.sh" ]; then
  echo "ERROR: $REPO_DIR 不是 ajouatom/openpilot 仓库根目录" >&2
  exit 1
fi
echo "REPO_DIR=$REPO_DIR"

# ① 确认 git 克隆（本仓库是嵌套 git；浅克隆也够用）
if [ ! -d "$REPO_DIR/.git" ] && [ ! -f "$REPO_DIR/.git" ]; then
  echo "没有 .git，假定仓库已就位；如需重新克隆：git clone https://github.com/ajouatom/openpilot $REPO_DIR" >&2
fi

# ② 装 Python 3.12（pyproject 要求 >=3.12.3,<3.13；系统 3.13 不满足）
if ! command -v uv >/dev/null; then
  echo "缺少 uv。安装：curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
  exit 1
fi
uv python install 3.12

# ③ 建 venv + 依赖（testing=首次构建要 catch2；tools=模拟器 metadrive/panda3d/bootstrap-icons）
uv sync --python 3.12 --extra testing --extra tools

echo ""
echo "run1 完成。下一步：./run2_build.sh"
