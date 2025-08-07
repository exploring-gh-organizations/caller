FROM python:3.12-alpine

# Build args
ARG PRECOMMIT_CONFIG_PATH="pre-commit-config.yaml"
ARG GIT_USER_EMAIL="ci@localhost"
ARG GIT_USER_NAME="CI Bot"

# Install system dependencies, hadolint, Python tools, and JS tools in fewer layers
RUN apk add --no-cache --upgrade \
  git=~2.45 \
  curl=~8.9 \
  shellcheck=~0.10 \
  nodejs=~20.15 \
  npm=~10.8 \
  wget=~1.24 \
  bash=~5.2 \
  sqlite=~3.49 && \
  # Install hadolint
  wget --progress=dot:giga -O /usr/local/bin/hadolint \
  https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 && \
  chmod +x /usr/local/bin/hadolint && \
  # Install Python tools
  pip install --no-cache-dir --upgrade pip==25.2 setuptools==75.8.0 && \
  pip install --no-cache-dir \
  pre-commit==4.0.1 \
  ruff==0.8.2 \
  black==24.10.0 \
  bandit==1.7.10 && \
  # Install JavaScript tools
  npm install -g \
  prettier@3.3.3 \
  @biomejs/biome@1.9.4

# Set working directory
WORKDIR /workspace

# Set git config
RUN git config --global --add safe.directory '*' && \
  git config --global user.email "${GIT_USER_EMAIL}" && \
  git config --global user.name "${GIT_USER_NAME}"

# Copy pre-commit config
COPY ${PRECOMMIT_CONFIG_PATH} /app/.pre-commit-config.yaml

# Simple entrypoint - install hooks at runtime when git repo is available
CMD ["sh", "-c", "cp /app/.pre-commit-config.yaml . && pre-commit install-hooks && pre-commit run --all-files"]
