#!/bin/bash

# Configuration
TOTAL_ISSUES=5                   # Change this to the exact number of issues you want
REPO_OWNER="ryomenhaider"       # Your GitHub username
REPO_NAME="commits"            # Your repository name

FULL_REPO="$REPO_OWNER/$REPO_NAME"

# Sample data pools to mix and match unique issues
TITLES=(
    "Refactor database connection pool"
    "Fix memory leak in authentication middleware"
    "Update out-of-date npm dependencies"
    "Implement localized error messages"
    "Add integration tests for the checkout API"
)

BODIES=(
    "The current implementation causes intermittent timeout errors under heavy load. Needs optimization."
    "Security scan flagged 3 medium vulnerabilities in old packages. We need to bump versions."
    "Non-English users are seeing generic raw error strings. We need to map these to translation keys."
    "Test coverage is below our 80% threshold for this module. Adding edge-case coverage."
)

LABELS=("bug" "enhancement" "documentation" "good first issue")

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    exit 1
fi

echo "Starting creation of $TOTAL_ISSUES GitHub Issues..."

for ((i=1; i<=TOTAL_ISSUES; i++))
do
    # Select random elements from the data pools
    RAND_TITLE_IDX=$(( RANDOM % ${#TITLES[@]} ))
    RAND_BODY_IDX=$(( RANDOM % ${#BODIES[@]} ))
    RAND_LABEL_IDX=$(( RANDOM % ${#LABELS[@]} ))
    
    # Construct unique titles and bodies
    ISSUE_TITLE="${TITLES[$RAND_TITLE_IDX]} (Task #$i)"
    ISSUE_BODY="${BODIES[$RAND_BODY_IDX]} \n\n_Automated tracking entry #$i created on $(date)_"
    ISSUE_LABEL="${LABELS[$RAND_LABEL_IDX]}"

    echo "[$i/$TOTAL_ISSUES] Creating issue..."
    
    # Create the issue via GitHub CLI
    ISSUE_URL=$(gh issue create \
        --repo "$FULL_REPO" \
        --title "$ISSUE_TITLE" \
        --body -e "$ISSUE_BODY" \
        --label "$ISSUE_LABEL")

    echo "Successfully created: $ISSUE_URL"

    # 2-second pause to prevent triggering GitHub secondary rate limits
    sleep 2
done

echo "Done! All $TOTAL_ISSUES Issues have been created."

