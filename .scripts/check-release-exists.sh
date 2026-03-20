#!/bin/bash
# Checks if a GitHub release exists in the current repository.
# Required environment variables: RELEASE_NAME, GITHUB_TOKEN, GITHUB_OUTPUT

set -euo pipefail

if gh release view "$RELEASE_NAME" --json tagName > /dev/null 2>&1; then
  echo "::warning::Release '$RELEASE_NAME' already exists."
  echo "ReleaseExists=true" >> "$GITHUB_OUTPUT"
else
  echo "Release '$RELEASE_NAME' not found."
  echo "ReleaseExists=false" >> "$GITHUB_OUTPUT"
fi
