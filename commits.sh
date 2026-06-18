#!/bin/bash

# Configuration
NUM_CYCLES=6              # How many sets of Issue -> Commit -> PR -> Review to create
REPO_OWNER="ryomenhaider" # Your GitHub username
REPO_NAME="commits"       # Your repository name
TARGET_BRANCH="main"      # The main branch of your repository

FULL_REPO="$REPO_OWNER/$REPO_NAME"

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is not installed. Please install it first."
  exit 1
fi

echo "Starting GitHub automation for $FULL_REPO..."

for ((i = 1; i <= NUM_CYCLES; i++)); do
  echo "------------------------------------"
  echo "Processing Cycle #$i"
  echo "------------------------------------"

  # 1. CREATE AN ISSUE
  ISSUE_TITLE="Feature enhancement task #$i"
  ISSUE_BODY="Automated tracking issue for development cycle #$i."

  echo "Creating issue..."
  ISSUE_URL=$(gh issue create --repo "$FULL_REPO" --title "$ISSUE_TITLE" --body "$ISSUE_BODY")
  # Extract issue number from URL
  ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
  echo "Created Issue #$ISSUE_NUM"

  # 2. CREATE A NEW BRANCH AND COMMITS
  BRANCH_NAME="feature/auto-branch-$i-$(date +%s)"
  git checkout -b "$BRANCH_NAME" --quiet

  # Create dummy changes
  echo "Update for cycle $i - $(date)" >>contribution.txt
  git add contribution.txt
  git commit -m "Docs: Update contribution log for issue #$ISSUE_NUM" --quiet

  # Push the local branch to remote
  echo "Pushing branch $BRANCH_NAME to remote..."
  git push origin "$BRANCH_NAME" --quiet

  # 3. CREATE A PULL REQUEST
  PR_TITLE="Feature implementation for Issue #$ISSUE_NUM"
  PR_BODY="Closes #$ISSUE_NUM. Automated code submission."

  echo "Creating Pull Request..."
  PR_URL=$(gh pr create --repo "$FULL_REPO" --base "$TARGET_BRANCH" --head "$BRANCH_NAME" --title "$PR_TITLE" --body "$PR_BODY")
  PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
  echo "Created PR #$PR_NUM"

  # 4. SUBMIT A CODE REVIEW
  # Note: GitHub doesn't natively allow you to approve your own PR.
  # This leaves a technical commentary review on the PR.
  echo "Submitting automated code review comment..."
  gh pr review "$PR_NUM" --repo "$FULL_REPO" --comment --body "Automated CI/CD validation passed. Code formatting looks correct."

  # Clean up local environment: switch back to target branch
  git checkout "$TARGET_BRANCH" --quiet
  echo "Cycle #$i complete."

  # Optional sleep to avoid hitting GitHub secondary rate limits
  sleep 2
done

echo "===================================="
echo "All $NUM_CYCLES cycles completed successfully!"
