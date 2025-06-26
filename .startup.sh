#!/bin/bash

set -ex

# This script installs everything from scratch and sets up chezmoi with SSH deploy key support.

# Install XCode Command Line Tools if necessary
xcode-select --install || echo "XCode already installed"

# Install Homebrew if necessary
if command -v brew >/dev/null 2>&1; then
    echo 'Homebrew is already installed'
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (
        echo
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
    ) >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install chezmoi
brew install chezmoi

# Generate SSH key if it doesn't already exist
SSH_KEY="$HOME/.ssh/chezmoi_deploy_key"
if [ ! -f "$SSH_KEY" ]; then
    ssh-keygen -t ed25519 -C "chezmoi deploy key" -f "$SSH_KEY" -N ""
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"
else
    echo "SSH key already exists at $SSH_KEY"
fi

# Output public key for deploy use
echo "Add the following SSH public key as a deploy key to your GitHub repository:"
cat "${SSH_KEY}.pub"

echo ""
read -p "Press enter to continue after the key has been added..."

# Initialize and apply chezmoi using SSH
chezmoi init d4lan --ssh
chezmoi apply