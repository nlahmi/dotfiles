#!/bin/bash

sudo apt update
sudo apt install curl git zsh fzf wezterm ... -y

# Install starship
curl -sS https://starship.rs/install.sh | sh -s -- -f

# Install fzf (in apt it's currently an outdated version)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc

# Install Zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Set zsh as the defualt shell for the current user
sudo chsh $USER -s /bin/zsh

# Install chezmoi and Pull configurations
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply nlahmi

# TODO: Add nvim dependencies (or run its own setup script)
