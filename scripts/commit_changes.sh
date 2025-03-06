#!/bin/bash

# Check if a commit message is provided
if [ -z "$1" ]; then
  echo "Please provide a commit message."
  exit 1
fi

# Add all changes
git add .

# Commit changes with the provided message
git commit -m "$1"

# Check for errors during commit
if [ $? -ne 0 ]; then
  echo "Commit failed."
  exit 1
fi

echo "Changes committed successfully."
