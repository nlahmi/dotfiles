#!/bin/bash

# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Apply
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nlahmi

# TODO: Add nvim dependencies (or run its own setup script)
