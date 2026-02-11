@echo off
setlocal enableextensions enabledelayedexpansion

set "IMAGE=agentsandbox"

REM Resolve workspace root as the parent directory of this script (AgentSandbox/..)
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "WORKSPACE_DIR=%%~fI"

REM Ensure Claude Code config file persists across container runs.
if not exist "%USERPROFILE%\.claude.json" (
  echo Creating "%USERPROFILE%\.claude.json" for container persistence...
  >"%USERPROFILE%\.claude.json" echo {}
)

set "MOUNT_WORKSPACE=%WORKSPACE_DIR%:/workspace"
set "MOUNT_CLAUDE_DIR=%USERPROFILE%\.claude:/home/agent/.claude"
set "MOUNT_CLAUDE_JSON=%USERPROFILE%\.claude.json:/home/agent/.claude.json"
set "MOUNT_CODEX=%USERPROFILE%\.codex:/home/agent/.codex"

set "ENV_ARGS="
if defined OPENAI_API_KEY set "ENV_ARGS=%ENV_ARGS% -e OPENAI_API_KEY"
if defined OPENAI_ORG set "ENV_ARGS=%ENV_ARGS% -e OPENAI_ORG"
if defined OPENAI_BASE_URL set "ENV_ARGS=%ENV_ARGS% -e OPENAI_BASE_URL"
if defined ANTHROPIC_API_KEY set "ENV_ARGS=%ENV_ARGS% -e ANTHROPIC_API_KEY"
if defined ANTHROPIC_BASE_URL set "ENV_ARGS=%ENV_ARGS% -e ANTHROPIC_BASE_URL"
if defined HTTP_PROXY set "ENV_ARGS=%ENV_ARGS% -e HTTP_PROXY"
if defined HTTPS_PROXY set "ENV_ARGS=%ENV_ARGS% -e HTTPS_PROXY"
if defined NO_PROXY set "ENV_ARGS=%ENV_ARGS% -e NO_PROXY"

echo ========================================
echo   AgentSandbox - Autonomous Mode
echo ========================================
echo Workspace: "%WORKSPACE_DIR%"
echo.
echo Choose your agent:
echo   1. Claude Code (autonomous)
echo   2. OpenAI Codex (autonomous)
echo   3. Bash (manual)
echo   4. Claude + Codex (MCP cross-validate)
echo.
set /p choice="Enter choice (1/2/3/4): "
echo.

if "%choice%"=="1" goto CLAUDE
if "%choice%"=="2" goto CODEX
if "%choice%"=="3" goto BASH
if "%choice%"=="4" goto CROSS

goto CLAUDE

:CROSS
echo Configuring Claude to use Codex via MCP...
docker run -it --rm -v "%MOUNT_WORKSPACE%" -v "%MOUNT_CLAUDE_DIR%" -v "%MOUNT_CLAUDE_JSON%" -v "%MOUNT_CODEX%" %ENV_ARGS% %IMAGE% bash -lc "/workspace/AgentSandbox/scripts/setup_mcp_codex.sh"
echo Starting Claude Code (cross-validate enabled)...
docker run -it --rm -v "%MOUNT_WORKSPACE%" -v "%MOUNT_CLAUDE_DIR%" -v "%MOUNT_CLAUDE_JSON%" -v "%MOUNT_CODEX%" %ENV_ARGS% %IMAGE% bash -lc "claude --dangerously-skip-permissions"
goto END

:CLAUDE
echo Starting Claude Code (full-auto)...
docker run -it --rm -v "%MOUNT_WORKSPACE%" -v "%MOUNT_CLAUDE_DIR%" -v "%MOUNT_CLAUDE_JSON%" -v "%MOUNT_CODEX%" %ENV_ARGS% %IMAGE% bash -lc "claude --dangerously-skip-permissions"
goto END

:CODEX
echo Starting OpenAI Codex (full-auto)...
docker run -it --rm -v "%MOUNT_WORKSPACE%" -v "%MOUNT_CLAUDE_DIR%" -v "%MOUNT_CLAUDE_JSON%" -v "%MOUNT_CODEX%" %ENV_ARGS% %IMAGE% bash -lc "codex --full-auto -a never"
goto END

:BASH
echo Starting Bash shell...
docker run -it --rm -v "%MOUNT_WORKSPACE%" -v "%MOUNT_CLAUDE_DIR%" -v "%MOUNT_CLAUDE_JSON%" -v "%MOUNT_CODEX%" %ENV_ARGS% %IMAGE% bash
goto END

:END
echo.
echo Session ended.
pause
