#!/usr/bin/env bash

# BBeautify Installer
# Installs jsbeautifier and copies BBeautify.py to BBEdit's Text Filters directory.
# Requires: python3, pip3, BBEdit

FILE_NAME="BBeautify.py"
SANDBOXED="$HOME/Library/Containers/com.barebones.bbedit/Data/Library/Application Support/BBEdit/Text Filters"
STANDARD="$HOME/Library/Application Support/BBEdit/Text Filters"

# bailbailbailbail if BBeautify.py isn't in the current directory
if [ ! -f "$FILE_NAME" ]; then
    echo "Error: $FILE_NAME not found in current directory."
    echo "Run this script from the same folder as $FILE_NAME."
    exit 1
fi

# bailbailbail if python3 isn't installed
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 not found."
    echo "Install it from https://python.org or via Homebrew: brew install python"
    exit 0
fi

# bailbail if pip3 isn't installed
if ! command -v pip3 &>/dev/null; then
    echo "Error: pip3 not found."
    echo "It should come with Python -- try reinstalling from https://python.org"
    exit 0
fi

# bail if BBEdit isn't installed: check CLI, then both possible app locations
if ! command -v bbedit &>/dev/null && \
   [ ! -d "/Applications/BBEdit.app" ] && \
   [ ! -d "$HOME/Applications/BBEdit.app" ]; then
    echo "Error: BBEdit not found."
    echo "Install it from https://www.barebones.com or the Mac App Store, then try again."
    exit 0
fi

# Confirm before making any changes
echo "BBeautify Installer"
echo "-------------------"
read -rp "Install BBeautify into BBEdit Text Filters? [y/n]: " confirm
case "$confirm" in
    y|Y) ;;
    *) echo "Cancelled."; exit 0 ;;
esac

# Install jsbeautifier via pip3
# --break-system-packages needed on newer macOS/Python setups; fallback for older
echo "Installing jsbeautifier..."
pip3 install jsbeautifier --break-system-packages 2>/dev/null || pip3 install jsbeautifier
echo "jsbeautifier installed."

# Copy filter to whichever Text Filters directories exist (could be both)
echo "Installing $FILE_NAME..."
INSTALLED=0
for DIR in "$SANDBOXED" "$STANDARD"; do
    if [ -d "$DIR" ]; then
        cp "$FILE_NAME" "$DIR/$FILE_NAME"
        chmod +x "$DIR/$FILE_NAME"
        echo "Installed to: $DIR"
        INSTALLED=1
    fi
done

# If neither directory existed, create the standard one and install there
if [ "$INSTALLED" -eq 0 ]; then
    echo "No Text Filters directory found. Creating standard location..."
    mkdir -p "$STANDARD"
    cp "$FILE_NAME" "$STANDARD/$FILE_NAME"
    chmod +x "$STANDARD/$FILE_NAME"
    echo "Installed to: $STANDARD"
fi

echo "Done."

# cleanup -- only offer to delete if we're running from the cloned repo directory.
# compare the git remote repo name to the current directory name to check.
# skip silently if there's no git remote (e.g., downloaded as a zip).
REPO_DIR=$(git remote get-url origin 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//')
BASE_DIR=$(basename "$PWD")

if [ "$INSTALLED" -eq 1 ] && [ -n "$REPO_NAME" ] && [ "$REPO_NAME" = "$CURRENT_DIR" ]; then
    read -rp $'\nDelete $PWD? [y/n]: ' del
    case "$del" in
        y|Y)
            cd .. && rm -rf "$OLDPWD"
            echo "Deleted."
            ;;
        *) echo "Skipping cleanup." ;;
    esac
fi
