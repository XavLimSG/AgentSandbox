# Security Policy

AgentSandbox is designed for autonomous agent workflows and intentionally enables full permissions inside the container. This increases risk. Use the guidance below to reduce exposure.

## Recommendations

- Use a dedicated workspace directory and mount only that path into the container.
- Avoid mounting your entire home directory or sensitive folders.
- Use least-privilege API keys and rotate them regularly.
- Keep secrets out of the workspace and source control.
- Consider running the container on a disposable VM or isolated machine.
- Restrict network egress if possible (firewall or Docker network rules).
- Audit agent prompts and tool usage, especially when running in autonomous mode.

## Reporting

If you discover a security issue, open a private report or contact the maintainers before public disclosure.
