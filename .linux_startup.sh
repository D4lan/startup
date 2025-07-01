#!/bin/sh

# Update Stuff
sudo apt-get update
sudo apt-get upgrade

# Install Homebrew
mkdir $HOME/homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $HOME/homebrew

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
$HOME/homebrew/bin/chezmoi init git@github-chezmoi:d4lan/dotfiles.git --ssh
$HOME/homebrew/bin/chezmoi apply
