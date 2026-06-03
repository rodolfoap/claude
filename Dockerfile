FROM debian:bookworm-slim
LABEL maintainer="rodolfoap@gmail.com"
LABEL description="Claude Code CLI container - Unofficial"
LABEL version="1.0"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update && apt-get install -y curl jq

RUN addgroup --system --gid 1000 claude
RUN adduser --system \
    --uid 1000 \
    --ingroup claude \
    --home /home/claude \
    --shell /bin/bash \
    --disabled-password \
    claude
USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash
WORKDIR /app
ENTRYPOINT ["/home/claude/.local/bin/claude"]
