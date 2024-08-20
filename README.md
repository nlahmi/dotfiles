# Installation
## Linux (Tested on Debian 12 only)
```
sudo apt update ; sudo apt install -y curl
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nlahmi/dotfiles/main/setup.sh)"
```

## Windows
Will install a Debian WSL2 environment and run the Linux script inside it.
```
iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/nlahmi/nvim-config/main/setup.ps1"))
```
