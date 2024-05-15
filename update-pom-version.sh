#!/bin/bash

# Get UNIX Date
DATE_UNIX=$(date +%s)

# Path to the pom.xml file
POM_FILE="pom.xml"

# Get the current version from the pom.xml file
CURRENT_VERSION="$(grep -oPm1 "(?<=<version>)[^<]+" "$POM_FILE")"
echo "Current version: $CURRENT_VERSION"

# Determine the type of change (major, minor, patch) based on the branch name
TYPE_OF_CHANGE=$(echo "$CURRENT_BRANCH" | cut -d'/' -f3)

# Increment the corresponding part of the version based on the type of change
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]%-*}

case $CURRENT_BRANCH in
  "feature/"*)
    VERSION_TYPE="-SNAPSHOT"
    case $TYPE_OF_CHANGE in
        "major")
            ((MAJOR++))
            ;;
        "minor")
            ((MINOR++))
            ;;
        "patch")
            ((PATCH++))
            ;;
        *)
            echo "Unrecognized type of change. Version is not updated."
            exit 1
            ;;
    esac
    ;;
  "develop")
    VERSION_TYPE="-SNAPSHOT"
    ;;
  "release")
    VERSION_TYPE="-RC"
    ;;
  "main")
    VERSION_TYPE=""
    ;;
  *)
    echo "Unrecognized type of branch. Version is not updated."
    exit 1
    ;;
esac

# Construct the new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH$VERSION_TYPE"

# Concatenate DATE_UNIX to the new version if CURRENT_JOB is "Deploy"
if [[ "$CURRENT_JOB" == "Deploy" ]]; then
  NEW_VERSION="$NEW_VERSION-$DATE_UNIX"
fi

# Update the version in the pom.xml file
sed -i "s|<version>$CURRENT_VERSION|<version>$NEW_VERSION|g" "$POM_FILE"

# Print the new version
echo "Version updated: $NEW_VERSION"