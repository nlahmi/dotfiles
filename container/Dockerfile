FROM debian:trixie-slim

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      zsh tmux git curl wget unzip ca-certificates gnupg sudo locales \
      openssh-client build-essential \
      ripgrep fd-find bat htop eza nodejs npm \
      python3 python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8

# bat/fd are namespaced on Debian to avoid clashes
RUN ln -s /usr/bin/batcat /usr/local/bin/bat \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd

# Neovim (matching the version used by nvim-config; tarball avoids FUSE/AppImage)
ARG NVIM_VERSION=v0.11.5
RUN set -e; \
    case "$TARGETARCH" in \
      arm64) NV_ARCH=arm64 ;; \
      *)     NV_ARCH=x86_64 ;; \
    esac; \
    curl -fLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NV_ARCH}.tar.gz"; \
    tar -C /opt -xf /tmp/nvim.tar.gz; \
    ln -s "/opt/nvim-linux-${NV_ARCH}/bin/nvim" /usr/local/bin/nvim; \
    rm -f /tmp/nvim.tar.gz

# Docker CLI only (talks to the host daemon via a mounted /var/run/docker.sock)
ARG DOCKER_VERSION=29.6.0
RUN set -e; \
    case "$TARGETARCH" in \
      arm64) DK_ARCH=aarch64 ;; \
      *)     DK_ARCH=x86_64 ;; \
    esac; \
    curl -fLo /tmp/docker.tgz "https://download.docker.com/linux/static/stable/${DK_ARCH}/docker-${DOCKER_VERSION}.tgz"; \
    tar -C /tmp -xf /tmp/docker.tgz docker/docker; \
    install /tmp/docker/docker /usr/local/bin/docker; \
    rm -rf /tmp/docker /tmp/docker.tgz

# Non-root user with passwordless sudo
RUN useradd -m -s /usr/bin/zsh dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev
ENV PATH="/home/dev/.local/bin:${PATH}"
RUN mkdir -p /home/dev/.local/bin

# starship, zoxide, fzf, chezmoi (all support arm64/amd64)
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y \
      -b /home/dev/.local/bin
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /home/dev/.fzf \
    && /home/dev/.fzf/install --bin \
    && ln -s /home/dev/.fzf/bin/fzf /home/dev/.local/bin/fzf
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/dev/.local/bin

# lazygit (arch-specific release asset)
RUN set -e; \
    case "$TARGETARCH" in \
      arm64) LG_ARCH=arm64 ;; \
      *)     LG_ARCH=x86_64 ;; \
    esac; \
    LG_VER=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*'); \
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VER}_Linux_${LG_ARCH}.tar.gz"; \
    tar -C /tmp -xf /tmp/lazygit.tar.gz lazygit; \
    install /tmp/lazygit /home/dev/.local/bin; \
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz

# Claude Code (native installer, self-updating, no node dependency)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Bake in dotfiles
RUN /home/dev/.local/bin/chezmoi init --apply nlahmi

# Neovim config + plugins (headless Lazy install)
RUN git clone --depth 1 https://github.com/nlahmi/nvim-config ~/.config/nvim \
    && nvim --headless "+Lazy! install" +qa

CMD ["zsh"]
