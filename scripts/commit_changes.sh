#!/bin/bash
# This script commits all current changes in the repository.
# Usage: ./commit_changes.sh "Commit message"
if [ -z "$1" ]; then
  echo "Error: Commit message required."
  echo "Usage: ./commit_changes.sh \"Commit message\""
  exit 1
fi

echo "Adding all changes..."
git add -A

echo "Committing with message: $1"
git commit -m "$1"

if [ $? -eq 0 ]; then
  echo "Changes committed successfully."
else
  echo "No changes were committed. Please check if there are staged modifications."
fi
