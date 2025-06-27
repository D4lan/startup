#!/bin/sh

# Install chezmoi
sudo apt update
sudo apt upgrade
sudo apt install chezmoi

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

# Initialize and apply chezmoi using SSH
chezmoi init git@github-chezmoi:d4lan/dotfiles.git --ssh
chezmoi apply
