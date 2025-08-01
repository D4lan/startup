#!/bin/sh

# Make sure updated
sudo apt-get update
sudo apt-get upgrade
# Used for Homebrew
sudo apt-get -y install build-essential

# Install Homebrew if not installed
if command -v brew >/dev/null 2>&1; then
    echo 'Homebrew is already installed'
else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'Homebrew is now installed'
fi

# Load it for this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install Chezmoi
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

# Ensure SSH config entry exists
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host github-chezmoi" "$SSH_CONFIG" 2>/dev/null; then
    {
        echo ""
        echo "Host github-chezmoi"
        echo "    HostName github.com"
        echo "    User git"
        echo "    IdentityFile ~/.ssh/chezmoi_deploy_key"
        echo "    IdentitiesOnly yes"
    } >> "$SSH_CONFIG"
    echo "Added SSH config entry for github-chezmoi"
fi

# Output public key for deploy use
echo "Add the following SSH public key as a deploy key to your GitHub repository:"
cat "${SSH_KEY}.pub"

echo ""
read -p "Press enter to continue after the key has been added..."

# Initialize and apply chezmoi using SSH
chezmoi init git@github-chezmoi:d4lan/dotfiles.git --ssh
chezmoi apply
