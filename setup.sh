#!/bin/bash

mkdir -p ~/.local/bin
sudo mkdir -p /etc/apt/keyrings
sudo apt-get update
sudo apt-get install curl gnupg2 wget -y

# Running on WSL
if [[ -n "$WSL_DISTRO_NAME" ]]; then

  # Wslu (mainly for clipboard support but does more)
  sudo apt install gnupg2 apt-transport-https
  wget -O - https://pkg.wslutiliti.es/public.key | sudo gpg -o /usr/share/keyrings/wslu-archive-keyring.pgp --dearmor
  echo "deb [signed-by=/usr/share/keyrings/wslu-archive-keyring.pgp] https://pkg.wslutiliti.es/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/wslu.list

  # Git Credentials Manager integration
  gcm=$(printf "%q" "$(realpath "$(dirname "$(which git.exe)")/../mingw64/bin/git-credential-manager.exe")")
  git config --global credential.helper $gcm
  
  sudo apt update
  sudo apt install wslu
  
# Not running on WSL
else

  # Wezterm
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list

  ## Kanata
  # Add user to the correct groups
  sudo groupadd uinput
  sudo usermod -aG input $USER
  sudo usermod -aG uinput $USER
  newgrp input
  newgrp uinput
  # Give the uint group the right permissions
  sudo echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' > /etc/udev/rules.d/99-input.rules
  sudo udevadm control --reload-rules && sudo udevadm trigger
  # May not be required
  sudo modprobe uinput
  # Download Kanata
  wget -O $HOME/.local/bin/kanata https://github.com/jtroo/kanata/releases/download/v1.7.0/kanata
  chmod +x $HOME/.local/bin/kanata
  # Install as a systemd service
  systemctl --user daemon-reload
  systemctl --user enable --now kanata.service

  #sudo apt-get update
  #sudo apt-get install wezterm -y
fi

# Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# eza
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

# k9s
# curl -sS https://webi.sh/k9s | sh

# Pyenv
curl https://pyenv.run | bash
sudo apt update
sudo apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
pyenv install 3.13
pyenv global 3.13

# UV (pip, venv, pyenv replacement)
# curl -LsSf https://astral.sh/uv/install.sh | sh

# Install stuff, ignoring those that failed or don't exist in our repos
sudo apt-get update
for i in unzip wget git zsh helm kubectl eza bat htop wezterm; do
  sudo apt-get install $i -y
done

# Create `bat` to `batcat` symlink (needed bc name clash with another package)
ln -s /usr/bin/batcat ~/.local/bin/bat

# Install starship
curl -sS https://starship.rs/install.sh | sh -s -- -f

# Install fzf (in apt it's currently an outdated version)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc

# Install Zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz

# Install yazi
YAZI_FILENAME="yazi-x86_64-unknown-linux-gnu"
wget https://github.com/sxyazi/yazi/releases/download/v0.2.5/${YAZI_FILENAME}.zip
unzip ${YAZI_FILENAME}.zip  # ${YAZI_FILENAME}/ya ${YAZI_FILENAME}/yazi
sudo install ${YAZI_FILENAME}/ya ${YAZI_FILENAME}/yazi /usr/local/bin
rm -rf ${YAZI_FILENAME} ${YAZI_FILENAME}.zip

# Set zsh as the defualt shell for the current user
sudo chsh $USER -s /bin/zsh

# Install chezmoi and Pull configurations
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply nlahmi

# Symlinks for stuff that use different config paths for different OSes
ln -s ~/AppData/Local/k9s ~/.config/

# Install Neovim
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nlahmi/nvim-config/main/setup-debian.sh)"
