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

# Make zsh the login shell
chsh -s zsh

# Pull and apply dotfiles (chezmoi comes from pkg, no bootstrap needed)
chezmoi init --apply nlahmi
