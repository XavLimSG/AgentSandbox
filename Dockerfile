FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    wget \
    unzip \
    python3 \
    python3-pip \
    ripgrep \
    jq \
    sudo \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Claude Code + OpenAI Codex CLIs
RUN npm install -g @anthropic-ai/claude-code @openai/codex

# Optional analysis tools (safe defaults; remove if not needed)
RUN pip3 install --no-cache-dir \
    semgrep \
    bandit \
    safety \
    pyyaml \
    requests

# Non-root user with passwordless sudo for full access inside container
RUN useradd -m -s /bin/bash agent && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /workspace
RUN chown -R agent:agent /workspace

USER agent

RUN git config --global init.defaultBranch main && \
    git config --global advice.detachedHead false

CMD ["/bin/bash"]
