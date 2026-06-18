#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Target branch that you want to keep (usually main or master)
MAIN_BRANCH="main"

echo "🔄 Fetching latest updates from remote and pruning deleted tracking branches..."
git fetch --prune

# Switch to your main branch first
echo "🌿 Switching to '$MAIN_BRANCH' branch..."
git checkout "$MAIN_BRANCH"
git pull

echo "🔍 Finding merged local branches..."
# Lists branches merged into current branch, filters out the main branch and the current active branch
MERGED_BRANCHES=$(git branch --merged | grep -v -E "^\*|^\s*($MAIN_BRANCH|master|development)$" || true)

if [ -z "$MERGED_BRANCHES" ]; then
  echo "✅ No merged local branches to remove."
else
  echo "The following merged local branches will be deleted:"
  echo "$MERGED_BRANCHES"

  read -p "⚠️ Are you sure you want to delete these local branches? (y/N): " CONFIRM_LOCAL
  if [[ "$CONFIRM_LOCAL" =~ ^[Yy]$ ]]; then
    # Remove whitespace and delete each branch
    echo "$MERGED_BRANCHES" | xargs -r git branch -d
    echo "✅ Local cleanup complete."
  else
    echo "Local cleanup canceled."
  fi
fi

echo "------------------------------------------------"
echo "🌐 Checking for remote branches on GitHub..."

# Prompt for repository to prevent accidental remote deletion
read -p "Enter the GitHub repository to check remote branches (owner/repo): " REPO

if [ -z "$REPO" ]; then
  echo "Skipping remote cleanup."
  exit 0
fi

# Fetch remote branches natively using GitHub REST API via gh api
REMOTE_BRANCHES=$(gh api repos/"$REPO"/branches --jq '.[].name' | grep -v -E "^($MAIN_BRANCH|master|development)$" || true)

if [ -z "$REMOTE_BRANCHES" ]; then
  echo "✅ No extra remote branches found."
  exit 0
fi

echo "The following remote branches were found on GitHub:"
echo "$REMOTE_BRANCHES"

read -p "⚠️ Do you want to delete these remote branches from GitHub? (y/N): " CONFIRM_REMOTE
if [[ "$CONFIRM_REMOTE" =~ ^[Yy]$ ]]; then
  for BRANCH in $REMOTE_BRANCHES; do
    echo "Deleting remote branch: $BRANCH..."
    git push origin --delete "$BRANCH" || echo "Could not delete $BRANCH (it might already be gone)."
  done
  echo "✅ Remote cleanup complete."
else
  echo "Remote cleanup canceled."
fi
