#!/bin/bash
# Checks if a GitHub release exists in the current repository.
# Required environment variables: RELEASE_NAME, GITHUB_TOKEN, GITHUB_OUTPUT

# Validate required environment variables before enabling strict mode
if [[ -z "${RELEASE_NAME:-}" ]]; then
  echo "::error::Required environment variable RELEASE_NAME is not set."
  exit 1
fi
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "::error::Required environment variable GITHUB_TOKEN is not set."
  exit 1
fi
if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
  echo "::error::Required environment variable GITHUB_OUTPUT is not set."
  exit 1
fi

set -euo pipefail

if gh release view "$RELEASE_NAME" --json tagName > /dev/null 2>&1; then
  echo "::warning::Release '$RELEASE_NAME' already exists."
  echo "ReleaseExists=true" >> "$GITHUB_OUTPUT"
else
  echo "Release '$RELEASE_NAME' not found."
  echo "ReleaseExists=false" >> "$GITHUB_OUTPUT"
fi
