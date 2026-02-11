#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-agentsandbox}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$HOME/.claude" "$HOME/.codex"
if [[ ! -f "$HOME/.claude.json" ]]; then
  printf '%s\n' '{}' >"$HOME/.claude.json"
fi

ENV_VARS=(
  OPENAI_API_KEY
  OPENAI_ORG
  OPENAI_BASE_URL
  ANTHROPIC_API_KEY
  ANTHROPIC_BASE_URL
  HTTP_PROXY
  HTTPS_PROXY
  NO_PROXY
)
ENV_ARGS=()
for var in "${ENV_VARS[@]}"; do
  if [[ -n "${!var-}" ]]; then
    ENV_ARGS+=("-e" "$var")
  fi
done

run_container() {
  docker run -it --rm \
    -v "$WORKSPACE_DIR:/workspace" \
    -v "$HOME/.claude:/home/agent/.claude" \
    -v "$HOME/.claude.json:/home/agent/.claude.json" \
    -v "$HOME/.codex:/home/agent/.codex" \
    "${ENV_ARGS[@]}" \
    "$IMAGE" "$@"
}

echo "========================================"
echo "  AgentSandbox - Autonomous Mode"
echo "========================================"
echo "Workspace: $WORKSPACE_DIR"
echo
echo "Choose your agent:"
echo "  1. Claude Code (autonomous)"
echo "  2. OpenAI Codex (autonomous)"
echo "  3. Bash (manual)"
echo "  4. Claude + Codex (MCP cross-validate)"
echo
read -r -p "Enter choice (1/2/3/4): " choice
echo

case "${choice:-1}" in
  4)
    echo "Configuring Claude to use Codex via MCP..."
    run_container bash -lc "/workspace/AgentSandbox/scripts/setup_mcp_codex.sh"
    echo "Starting Claude Code (cross-validate enabled)..."
    run_container bash -lc "claude --dangerously-skip-permissions"
    ;;
  2)
    echo "Starting OpenAI Codex (full-auto)..."
    run_container bash -lc "codex --full-auto -a never"
    ;;
  3)
    echo "Starting Bash shell..."
    run_container bash
    ;;
  *)
    echo "Starting Claude Code (full-auto)..."
    run_container bash -lc "claude --dangerously-skip-permissions"
    ;;
esac
