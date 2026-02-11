# AgentSandbox

Run full‑permission Claude Code and OpenAI Codex with no fear inside a Docker container. This is a general‑purpose agent sandbox.

## Quick start

```bash
cd AgentSandbox
docker build -t agentsandbox .
./run.sh
```

Windows:

```bat
cd AgentSandbox
docker build -t agentsandbox .
run.bat
```

## Options

1. Claude Code (autonomous)
2. OpenAI Codex (autonomous)
3. Bash (manual)
4. Claude + Codex (MCP cross‑validate)

Option 4 configures Claude to call Codex via MCP and then launches Claude.

## Keys and login

You can authenticate either by API keys or by subscription login:

- API keys: set on your host and the launcher passes them into the container.
- Subscription login: run `claude /login` or `codex login` inside the container. Credentials persist across runs via mounted config directories.

## Environment variables

Only variables you set on the host are passed through:

- `OPENAI_API_KEY`
- `OPENAI_ORG`
- `OPENAI_BASE_URL`
- `ANTHROPIC_API_KEY`
- `ANTHROPIC_BASE_URL`
- `HTTP_PROXY`
- `HTTPS_PROXY`
- `NO_PROXY`

## Security notes

This container runs agents with full permissions inside the container. Treat it like executing an untrusted program:

- Use a dedicated workspace directory; do not mount your entire home directory.
- Use least‑privilege keys and rotate them regularly.
- Avoid placing production secrets in the workspace.
- Consider running on an isolated machine or VM for sensitive work.
