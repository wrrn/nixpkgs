#!/usr/bin/env bash
# Script to update the Monodraw package

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
FLAKE_PATH="$SCRIPT_DIR/default.nix"


echo "🔍 Found Monodraw Nix file at: $FLAKE_PATH"

# Temporary directory for downloads
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "🔍 Checking for the latest version of Monodraw..."

# Download the latest DMG to a temporary location
echo "📥 Downloading latest version..."
curl -L -o "$TEMP_DIR/monodraw-latest.dmg" https://updates.helftone.com/monodraw/downloads/monodraw-latest.dmg

# Extract version from DMG if possible
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🔧 Extracting version from DMG..."
  # Mount the DMG
  MOUNT_POINT=$(hdiutil attach -nobrowse -noautoopen "$TEMP_DIR/monodraw-latest.dmg" | tail -n 1 | awk '{print $3}')
  
  # Extract version from Info.plist
  if [ -d "$MOUNT_POINT/Monodraw.app" ]; then
    NEW_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$MOUNT_POINT/Monodraw.app/Contents/Info.plist")
    echo "📋 Found version: $NEW_VERSION"
  else
    echo "⚠️ Couldn't find Monodraw.app in DMG, using current version as fallback"
    NEW_VERSION=$(grep "version = " "$FLAKE_PATH" | head -n 1 | cut -d'"' -f2)
  fi
  
  # Unmount the DMG
  hdiutil detach "$MOUNT_POINT" -quiet
else
  echo "⚠️ Not on macOS, can't extract version from DMG"
  echo "⚠️ Using current version as fallback or manually set a version"
  NEW_VERSION=$(grep "version = " "$FLAKE_PATH" | head -n 1 | cut -d'"' -f2)
fi

# Calculate hash
echo "🔐 Calculating hash for the new download..."
NEW_HASH=$(nix hash file "$TEMP_DIR/monodraw-latest.dmg")
echo "📋 New hash: $NEW_HASH"

# Get current version and hash from the flake
CURRENT_VERSION=$(grep "version = " "$FLAKE_PATH" | head -n 1 | cut -d'"' -f2)
CURRENT_HASH=$(grep "hash = " "$FLAKE_PATH" | head -n 1 | cut -d'"' -f2)

echo "ℹ️ Current version: $CURRENT_VERSION"
echo "ℹ️ Current hash: $CURRENT_HASH"

# Check if the version or hash has changed
if [ "$NEW_VERSION" == "$CURRENT_VERSION" ] && [ "$NEW_HASH" == "$CURRENT_HASH" ]; then
  echo "✅ Monodraw is already up to date!"
  exit 0
fi

# Update the flake file
echo "📝 Updating flake file..."
sed -i "s|version = \"$CURRENT_VERSION\"|version = \"$NEW_VERSION\"|" "$FLAKE_PATH"
sed -i "s|hash = \"$CURRENT_HASH\"|hash = \"$NEW_HASH\"|" "$FLAKE_PATH"


echo "✅ Flake updated successfully!"
echo "ℹ️ New version: $NEW_VERSION"
echo "ℹ️ New hash: $NEW_HASH"
echo "🚀 You should now test the package to ensure it builds correctly."
