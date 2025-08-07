FROM python:3.11-slim

# Build args for flexibility
ARG PRECOMMIT_CONFIG_PATH="../../config/pre-commit-config.yaml"
ARG GIT_USER_EMAIL="ci@opencloudhub.dev"
ARG GIT_USER_NAME="OpenCloudHub CI"

# Echo the build args (just for illustration, has no runtime effect)
RUN echo "Using PRECOMMIT_CONFIG_PATH=${PRECOMMIT_CONFIG_PATH}" && \
    echo "GIT_USER_EMAIL=${GIT_USER_EMAIL}" && \
    echo "GIT_USER_NAME=${GIT_USER_NAME}"

# Entry point (just echo something on container run)
CMD echo "Container built with GIT_USER_NAME=${GIT_USER_NAME} and ready."
