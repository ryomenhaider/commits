#!/bin/bash

# Configuration
TOTAL_REVIEWS=50          # Exact number of reviews to submit
REPO_OWNER="ryomenhaider" # Your GitHub username
REPO_NAME="commits"       # Your repository name

FULL_REPO="$REPO_OWNER/$REPO_NAME"
REVIEW_MESSAGES=(
  "Code looks clean and follows the style guide. Nicely done."
  "Logic checks out. Validated the changes locally."
  "Great optimization on this block. Ready for merging."
  "Documentation is updated correctly alongside the implementation."
  "LGTM (Looks good to me). Code architecture is solid."
)

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is not installed."
  exit 1
fi

echo "Fetching open Pull Requests from $FULL_REPO..."

# Get a list of open PR numbers (up to the last 50)
PR_LIST=($(gh pr list --repo "$FULL_REPO" --state open --limit 50 --json number --jq '.[].number'))

if [ ${#PR_LIST[@]} -eq 0 ]; then
  echo "Error: No open Pull Requests found in $FULL_REPO to review."
  exit 1
fi

echo "Found ${#PR_LIST[@]} open Pull Requests. Starting review cycle..."

# Loop to create the specified number of reviews
for ((i = 1; i <= TOTAL_REVIEWS; i++)); do
  # Pick a PR from the array (loops back to the start if TOTAL_REVIEWS > open PRs)
  PR_INDEX=$(((i - 1) % ${#PR_LIST[@]}))
  TARGET_PR=${PR_LIST[$PR_INDEX]}

  # Pick a random comment from our message pool
  MSG_INDEX=$((RANDOM % ${#REVIEW_MESSAGES[@]}))
  SELECTED_MSG="${REVIEW_MESSAGES[$MSG_INDEX]}"

  echo "[$i/$TOTAL_REVIEWS] Submitting review on PR #$TARGET_PR..."

  # Submit the review via GitHub CLI
  # Options for --comment can be changed to --approve if reviewing someone else's code
  gh pr review "$TARGET_PR" \
    --repo "$FULL_REPO" \
    --comment \
    --body "$SELECTED_MSG (Automated Review #$i)"

  # Brief pause to avoid hitting GitHub rate limits
  sleep 2
done

echo "Done! Successfully submitted $TOTAL_REVIEWS code reviews."
