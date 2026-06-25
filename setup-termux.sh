#!/data/data/com.termux/files/usr/bin/bash
set -e

# Termux (Android) setup. A thin core layer of CLI tools and configs.
# Heavy dev work runs inside the proot-distro container (see container/).

pkg update -y
pkg upgrade -y

pkg install -y \
  git \
  zsh \
  tmux \
  openssh \
  curl \
  wget \
  chezmoi \
  starship \
  zoxide \
  fzf \
  bat \
  eza \
  htop

# Terminal font (Hack Nerd Font Mono, matching the wezterm config).
# Reuses the font committed in nvim-config. Termux reads its font from this exact path.
mkdir -p ~/.termux
curl -fLo ~/.termux/font.ttf https://raw.githubusercontent.com/nlahmi/nvim-config/main/fonts/Hack/HackNerdFontMono-Regular.ttf

# Make zsh the login shell
chsh -s zsh

# Pull and apply dotfiles (chezmoi comes from pkg, no bootstrap needed)
chezmoi init --apply nlahmi

# Apply the new font/settings
command -v termux-reload-settings >/dev/null && termux-reload-settings || true
