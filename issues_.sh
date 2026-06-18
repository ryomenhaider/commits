#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is not installed."
  echo "Please install it and run 'gh auth login' first."
  exit 1
fi

# Prompt for the repository to avoid accidental bulk closures
read -p "Enter the repository (format: owner/repo, e.g., octocat/hello-world): " REPO

if [ -z "$REPO" ]; then
  echo "Repository name cannot be empty."
  exit 1
fi

echo "Fetching all open issues for $REPO..."

# Fetch all open issue numbers (handles pagination up to 1000 issues)
ISSUE_NUMBERS=$(gh issue list --repo "$REPO" --state open --limit 1000 --json number --jq '.[].number')

if [ -z "$ISSUE_NUMBERS" ]; then
  echo "No open issues found in $REPO."
  exit 0
fi

# Count the number of issues found
ISSUE_COUNT=$(echo "$ISSUE_NUMBERS" | wc -l | tr -d ' ')

# Double-check confirmation to prevent accidental data loss
echo "⚠️  WARNING: You are about to close $ISSUE_COUNT open issues in $REPO."
read -p "Are you absolutely sure you want to proceed? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Operation canceled."
  exit 0
fi

# Loop through each issue and close it
echo "Closing issues..."
for NUM in $ISSUE_NUMBERS; do
  echo "Closing issue #$NUM..."
  gh issue close "$NUM" --repo "$REPO" --comment "Closing via automated script."
done

echo "✅ Success! All open issues have been closed."
