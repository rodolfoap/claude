FROM debian:bookworm-slim
LABEL maintainer="Ondřej Beňuš"
LABEL description="Claude Code CLI container - Unofficial"
LABEL version="1.0"
LABEL org.opencontainers.image.licenses="MIT"

# Install dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    curl \
    gosu \
    git \
    python3-full \
    python3-pip \
    build-essential \
    neovim \
    wget \
    mc \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI globally during build
RUN npm install -g @anthropic-ai/claude-code && \
    npm cache clean --force && \
    rm -rf /tmp/* /root/.npm

# Copy settings.json to ~/.claude/
COPY settings.json /root/.claude/settings.json

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Add health check for the unofficial container
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD bash -c "[ -x /usr/local/bin/claude ] && echo 'OK' || echo 'Claude not installed'"

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["claude"]
