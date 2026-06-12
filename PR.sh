#!/bin/bash

# Configuration
TOTAL_PRS=15              # Change this to the exact number of PRs you want
REPO_OWNER="ryomenhaider" # Your GitHub username
REPO_NAME="commits"       # Your repository name
TARGET_BRANCH="main"      # The base branch you want to merge into

FULL_REPO="$REPO_OWNER/$REPO_NAME"

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is not installed."
  exit 1
fi

echo "Starting creation of $TOTAL_PRS Pull Requests..."

for ((i = 1; i <= TOTAL_PRS; i++)); do
  # 1. Create a unique branch name using a timestamp
  BRANCH_NAME="update/pr-batch-$i-$(date +%s)"
  git checkout -b "$BRANCH_NAME" --quiet

  # 2. Make a unique modification to a file
  echo "PR modification #$i made on $(date)" >>pr_log.txt
  git add pr_log.txt
  git commit -m "Chore: Update log for PR #$i" --quiet

  # 3. Push the branch upstream
  echo "[$i/$TOTAL_PRS] Pushing branch $BRANCH_NAME..."
  git push origin "$BRANCH_NAME" --quiet

  # 4. Open the Pull Request via GitHub CLI
  PR_TITLE="Automated contribution updates (PR #$i)"
  PR_BODY="This is an automated pull request tracking submission #$i."

  echo "[$i/$TOTAL_PRS] Creating Pull Request..."
  PR_URL=$(gh pr create --repo "$FULL_REPO" --base "$TARGET_BRANCH" --head "$BRANCH_NAME" --title "$PR_TITLE" --body "$PR_BODY")

  echo "Successfully created: $PR_URL"

  # 5. Reset local branch back to main for the next loop
  git checkout "$TARGET_BRANCH" --quiet

  # 2-second pause to prevent triggering GitHub secondary rate limits
  sleep 2
done

echo "Done! All $TOTAL_PRS Pull Requests have been created."
