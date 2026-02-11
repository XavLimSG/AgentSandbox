#!/usr/bin/env bash
set -euo pipefail

# One-way MCP: Claude can call Codex for cross-validation.
# This avoids circular tool calls while enabling fast second opinions.

echo "[mcp] Configuring Claude Code to use Codex (server name: codex)..."
claude mcp remove codex >/dev/null 2>&1 || true
claude mcp add codex -- codex mcp-server

echo "[mcp] Cleaning up legacy MCP entries (if any)..."
claude mcp remove agent_share >/dev/null 2>&1 || true

echo "[mcp] Ensuring Codex is not configured to call Claude..."
codex mcp remove claude >/dev/null 2>&1 || true
