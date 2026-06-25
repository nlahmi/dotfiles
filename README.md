# Installation
## Linux (Tested on Debian 12 only)
```
sudo apt update ; sudo apt install -y curl
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nlahmi/dotfiles/main/setup.sh)"
```

## Windows
Will install a Debian WSL2 environment and run the Linux script inside it.
Run as Administrator!
```
iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/nlahmi/nvim-config/main/setup.ps1"))
```

## Termux (Android)
Installs a thin core layer of CLI tools and applies the dotfiles. Heavy dev work runs
inside the container (see `container/`).
```
pkg install -y curl
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nlahmi/dotfiles/main/setup-termux.sh)"
```

## Dev container
Full toolset incl. Claude Code, published to `ghcr.io/nlahmi/dev`. See [container/README.md](container/README.md).
On Android via proot-distro:
```
proot-distro install ghcr.io/nlahmi/dev:latest
proot-distro login dev
```
