#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if gh CLI is installed
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is not installed."
  echo "Please install it and log in using 'gh auth login'."
  exit 1
fi

# Fetch all open PR numbers into an array
echo "Fetching open pull requests..."
pr_list=$(gh pr list --state open --json number --jq '.[].number')

# Check if there are any open PRs
if [ -z "$pr_list" ]; then
  echo "No open pull requests found."
  exit 0
fi

# Loop through each PR number and close it
for pr in $pr_list; do
  echo "Closing PR #$pr..."
  gh pr close "$pr" --comment "Closing automatically via script."
done

echo "All open pull requests have been processed."
