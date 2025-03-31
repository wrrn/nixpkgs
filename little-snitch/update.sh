#!/usr/bin/env bash
# Script to update the Little Snitch package

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
FLAKE_PATH="$SCRIPT_DIR/default.nix"

echo "🔍 Found Little Snitch Nix file at: $FLAKE_PATH"

# Temporary directory for downloads
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "🔍 Checking for the latest version of Little Snitch..."

# Extract latest version from download page
echo "🔎 Fetching latest version information..."
LATEST_VERSION=$(curl -s "https://www.obdev.at/products/littlesnitch/download.html" | \
  grep -o 'LittleSnitch-[0-9.]*\.dmg' | \
  sed 's/LittleSnitch-\([0-9.]*\)\.dmg/\1/' | sort -V | tail -n1)

if [[ -z "$LATEST_VERSION" ]]; then
  echo "❌ Failed to find latest version on the website"
  exit 1
fi

echo "📋 Latest version found: $LATEST_VERSION"

# Download the latest DMG to a temporary location
DMG_URL="https://www.obdev.at/downloads/littlesnitch/LittleSnitch-${LATEST_VERSION}.dmg"
echo "📥 Downloading latest version from $DMG_URL..."
curl -L -o "$TEMP_DIR/littlesnitch-latest.dmg" "$DMG_URL"

# Calculate hash
echo "🔐 Calculating hash for the new download..."
NEW_HASH=$(nix hash file "$TEMP_DIR/littlesnitch-latest.dmg")
echo "📋 New hash: $NEW_HASH"

# Get current version and hash from the flake
CURRENT_VERSION=$(grep "version = " "$FLAKE_PATH" | head -n 1 | cut -d'"' -f2)
CURRENT_HASH=$(grep "hash = " "$FLAKE_PATH" | head -n 1 | cut -d'"' -f2)

echo "ℹ️ Current version: $CURRENT_VERSION"
echo "ℹ️ Current hash: $CURRENT_HASH"

# Check if the version or hash has changed
if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ] && [ "$NEW_HASH" == "$CURRENT_HASH" ]; then
  echo "✅ Little Snitch is already up to date!"
  exit 0
fi

# Update the flake file
echo "📝 Updating flake file..."
sed -i "s|version = \"$CURRENT_VERSION\"|version = \"$LATEST_VERSION\"|" "$FLAKE_PATH"
sed -i "s|hash = \"$CURRENT_HASH\"|hash = \"$NEW_HASH\"|" "$FLAKE_PATH"

echo "✅ Flake updated successfully!"
echo "ℹ️ New version: $LATEST_VERSION"
echo "ℹ️ New hash: $NEW_HASH"
echo "🚀 You should now test the package to ensure it builds correctly."
```
