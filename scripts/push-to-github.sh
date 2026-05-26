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
  # Generate dynamic commit message based on changed files
  if [[ -z "${COMMIT_MSG:-}" ]]; then
    CHANGED_FILES=$(git diff --cached --name-only)
    MODULES=()
    
    # Detect which modules/areas have changes
    [[ "$CHANGED_FILES" =~ agents/ ]] && MODULES+=("agents")
    [[ "$CHANGED_FILES" =~ api/ ]] && MODULES+=("api")
    [[ "$CHANGED_FILES" =~ ui/ ]] && MODULES+=("ui")
    [[ "$CHANGED_FILES" =~ graph/ ]] && MODULES+=("graph")
    [[ "$CHANGED_FILES" =~ knowledge_base/ ]] && MODULES+=("knowledge_base")
    [[ "$CHANGED_FILES" =~ docs/ ]] && MODULES+=("docs")
    [[ "$CHANGED_FILES" =~ tests/ ]] && MODULES+=("tests")
    [[ "$CHANGED_FILES" =~ deploy/ ]] && MODULES+=("deploy")
    [[ "$CHANGED_FILES" =~ scripts/ ]] && MODULES+=("scripts")
    [[ "$CHANGED_FILES" =~ streamlit_app.py ]] && MODULES+=("streamlit")
    [[ "$CHANGED_FILES" =~ requirements.txt ]] && MODULES+=("dependencies")
    
    if [[ ${#MODULES[@]} -gt 0 ]]; then
      MODULE_LIST=$(IFS=, ; echo "${MODULES[*]}")
      COMMIT_MSG="Update: ${MODULE_LIST}"
    else
      # Show actual files changed if no module matches
      FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
      FIRST_FILE=$(echo "$CHANGED_FILES" | head -1)
      COMMIT_MSG="Update: ${FIRST_FILE} (+$((FILE_COUNT-1)) more)"
    fi
  fi
  
  git commit -m "$COMMIT_MSG"
fi

if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin "$BRANCH"
else
  git remote add origin "$REMOTE"
  git push -u origin "$BRANCH"
fi

echo "Pushed to ${REMOTE} (${BRANCH})"
