#!/bin/bash
set -e

# Copy the pre-commit config to workspace
if [ ! -f ".pre-commit-config.yaml" ]; then
    echo "📥 Using pre-commit config from container..."
    cp /app/.pre-commit-config.yaml .
fi

# Run pre-commit with provided arguments
echo "🧪 Running code quality checks..."
exec pre-commit run "$@"
