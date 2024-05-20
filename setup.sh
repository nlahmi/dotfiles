#!/bin/bash

# Install wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# TODO: Install kubectl and k9s

sudo apt update
sudo apt install curl git zsh wezterm helm -y

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

# Symlinks for stuff that use different config paths for different OSes
ln -s ~/AppData/Local/k9s ~/.config/

# Install Neovim
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nlahmi/nvim-config/main/setup-debian.sh)"
