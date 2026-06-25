# Dev container

Debian-based image with the full CLI toolset (zsh, tmux, git, neovim, ripgrep, fd, bat,
eza, fzf, zoxide, starship, lazygit, node), Claude Code, and the dotfiles applied at build
time. No desktop/systemd/kanata/wezterm bits.

## Published image
GitHub Actions builds `linux/amd64,linux/arm64` and pushes to GHCR on changes to
`container/`:

    ghcr.io/nlahmi/dev:latest

The package is public, so no auth is needed to pull.

## Run on Android (Termux + proot-distro)
proot-distro 5.x pulls OCI images straight from a registry:

    pkg install proot-distro
    proot-distro install ghcr.io/nlahmi/dev:latest
    proot-distro login dev

## Run on a desktop

    docker run -it --rm ghcr.io/nlahmi/dev:latest

## Build locally

    docker build -t nlahmi-dev container/
    docker run -it --rm nlahmi-dev

For arm64 from an x86 host:

    docker buildx build --platform linux/arm64 -t nlahmi-dev container/

## Fallback: build on device
If the registry path is ever unavailable, build the Dockerfile natively on the phone
(slower, limited Dockerfile feature support):

    proot-distro build container/Dockerfile
