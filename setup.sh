#!/bin/bash

# Install chezmoi and Pull configurations
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nlahmi

# TODO: Add nvim dependencies (or run its own setup script)
