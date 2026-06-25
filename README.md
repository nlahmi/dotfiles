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

Ephemeral container with `~/Projects` mounted both ways:
```
docker run --rm -it -v ~/Projects:/home/dev/Projects ghcr.io/nlahmi/dev:latest
```
With host credentials (aws, kube, gh, git, ssh, Claude) mounted in:
```
docker run --rm -it \
  -v ~/Projects:/home/dev/Projects \
  -v ~/.aws:/home/dev/.aws \
  -v ~/.kube:/home/dev/.kube \
  -v ~/.config/gh:/home/dev/.config/gh \
  -v ~/.docker/config.json:/home/dev/.docker/config.json:ro \
  -v ~/.gitconfig:/home/dev/.gitconfig:ro \
  -v ~/.ssh:/home/dev/.ssh:ro \
  -v ~/.claude:/home/dev/.claude \
  -v ~/.claude.json:/home/dev/.claude.json \
  ghcr.io/nlahmi/dev:latest
```
On Android via proot-distro:
```
proot-distro install ghcr.io/nlahmi/dev:latest
proot-distro login dev
```
