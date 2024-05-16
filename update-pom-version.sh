#!/bin/bash

# Path to the pom.xml file
POM_FILE="pom.xml"

# Get the current version from the pom.xml file
CURRENT_VERSION="$(grep -oPm1 "(?<=<version>)[^<]+" "$POM_FILE")"
echo "Current version: $CURRENT_VERSION"

# Concatenate DATE_UNIX to the new version if CURRENT_JOB is "Deploy"
if [[ "$DEPLOY_CLOUDHUB" ]]; then
  NEW_VERSION="$NEW_VERSION-$(date +%s)"
  # Update the version in the pom.xml file
  sed -i "s|<version>$CURRENT_VERSION|<version>$NEW_VERSION|g" "$POM_FILE"
else
  # Update the version in the pom.xml file
  sed -i "s|<version>$CURRENT_VERSION|<version>$NEW_VERSION|g" "$POM_FILE"
  # Print the new version
  echo "Version updated: $NEW_VERSION"
  # Add, commit and push to repo
fi
