FROM python:3.12-alpine

# Build args
ARG PRECOMMIT_CONFIG_PATH="pre-commit-config.yaml"
ARG GIT_USER_EMAIL="ci@localhost"
ARG GIT_USER_NAME="CI Bot"

# Install system dependencies
RUN apk add --no-cache --upgrade \
    git \
    curl \
    shellcheck \
    nodejs \
    npm \
    wget \
    bash \
    sqlite

# Install hadolint
RUN wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
    && chmod +x /usr/local/bin/hadolint

# Install Python tools
RUN pip install --no-cache-dir --upgrade pip setuptools>=78.1.1
RUN pip install --no-cache-dir \
    pre-commit \
    ruff \
    black \
    bandit

# Install JavaScript tools
RUN npm install -g \
    prettier \
    @biomejs/biome

# Set working directory
WORKDIR /workspace

# Set git config
RUN git config --global --add safe.directory '*' \
    && git config --global user.email "${GIT_USER_EMAIL}" \
    && git config --global user.name "${GIT_USER_NAME}"

# Copy pre-commit config
COPY ${PRECOMMIT_CONFIG_PATH} /app/.pre-commit-config.yaml

# Simple entrypoint - install hooks at runtime when git repo is available
CMD ["sh", "-c", "cp /app/.pre-commit-config.yaml . && pre-commit install-hooks && pre-commit run --all-files"]
