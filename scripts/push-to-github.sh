#!/usr/bin/env bash
# Initialize git (if needed) and push to GitHub — required before EC2 bootstrap clones the repo.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

REMOTE="${GIT_REMOTE:-https://github.com/lokeshadda/ai-incident-resolution.git}"
BRANCH="${GIT_BRANCH:-main}"

if [[ ! -f .gitignore ]]; then
  echo "Run from project root."
  exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  git init
  git branch -M "$BRANCH"
fi

git add -A
git status

if git diff --cached --quiet; then
  echo "Nothing to commit."
else
  git commit -m "${COMMIT_MSG:-Deploy: AI incident resolution agent}"
fi

if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin "$BRANCH"
else
  git remote add origin "$REMOTE"
  git push -u origin "$BRANCH"
fi

echo "Pushed to ${REMOTE} (${BRANCH})"
