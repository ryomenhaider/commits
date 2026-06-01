#!/bin/bash

# Configuration
TOTAL_COMMITS=10                 # Total number of contributions you want
COMMIT_MESSAGE="Code cleanup"    # The message for each commit
FILE_NAME="contribution.txt"     # The file that will be modified

# Ensure a git repository exists
if [ ! -d ".git" ]; then
    echo "Error: This directory is not a Git repository."
    echo "Please run 'git init' first."
    exit 1
fi

echo "Starting to create $TOTAL_COMMITS contributions..."

# Loop to create the exact number of commits
for ((i=1; i<=TOTAL_COMMITS; i++))
do
    # Append text to the file to create a unique change
    echo "Contribution #$i on $(date)" >> "$FILE_NAME"
    
    # Stage the change
    git add "$FILE_NAME"
    
    # Commit the change
    git commit -m "$COMMIT_MESSAGE (Batch #$i)" --quiet
done

echo "Successfully created $TOTAL_COMMITS local commits."
echo "Run 'git push origin <branch-name>' to push them to your remote profile."

