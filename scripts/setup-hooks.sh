#!/bin/bash

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Install pre-push hook
cp scripts/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push

echo "✅ Git hooks installed successfully"