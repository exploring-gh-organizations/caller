# Multi-stage build for smaller final image
FROM python:3.12-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (needed for JS tools)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Python tools
RUN pip install --no-cache-dir --upgrade pip setuptools>=78.1.1
RUN pip install --no-cache-dir \
    pre-commit \
    ruff \
    black \
    isort \
    bandit[toml] \
    safety \
    commitizen \
    cz-conventional-gitmoji \
    mypy \
    pylint \
    flake8

# Install JavaScript/TypeScript tools globally
RUN npm install -g \
    @biomejs/biome \
    prettier \
    eslint \
    @typescript-eslint/parser \
    @typescript-eslint/eslint-plugin

# Final stage
FROM python:3.12-slim

# Build arg for pre-commit config path
ARG PRECOMMIT_CONFIG_PATH=".pre-commit-config.yaml"
ARG GIT_USER_EMAIL="ci@localhost"
ARG GIT_USER_NAME="CI Bot"

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    shellcheck \
    hadolint \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js for runtime
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy Node.js global packages from builder
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin/biome /usr/local/bin/biome
COPY --from=builder /usr/local/bin/prettier /usr/local/bin/prettier
COPY --from=builder /usr/local/bin/eslint /usr/local/bin/eslint

# Set working directory
WORKDIR /workspace

# Set git config
RUN git config --global --add safe.directory /workspace \
    && git config --global user.email "${GIT_USER_EMAIL}" \
    && git config --global user.name "${GIT_USER_NAME}"

# Copy pre-commit config and install hooks
COPY ${PRECOMMIT_CONFIG_PATH} /app/.pre-commit-config.yaml
RUN cd /app && pre-commit install-hooks

# Entry script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--all-files"]
