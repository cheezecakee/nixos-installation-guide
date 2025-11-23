#!/usr/bin/env bash

cd "$HOME" || exit 1

git clone "https://github.com/cheezecakee/dotfiles.git"

# Create symlink for nix
if [ ! -L nix ]; then
    echo "Creating symlink ~/nix -> ~/dotfiles/nix"
    ln -s "$HOME/dotfiles/nix" "$HOME/nix"
fi 

# Create symlink for .config
if [ ! -L .config ]; then
    echo "Creating symlink ~/.config -> ~/dotfiles/.config"
    ln -s "$HOME/dotfiles/.config" "$HOME/.config"
fi

# Copy and overwrite hardware-configuration.nix
DOTFILES_HARDWARE="$HOME/dotfiles/nix/machines/hardware-configuration.nix"
SYSTEM_HARDWARE="/etc/nixos/hardware-configuration.nix"

if [ -f "$SYSTEM_HARDWARE" ]; then
    echo "Copying $SYSTEM_HARDWARE -> $DOTFILES_HARDWARE"
    cp -f "$SYSTEM_HARDWARE" "$DOTFILES_HARDWARE"
fi

cd "$HOME/nix" || exit 1 

echo "Building new nixos config"
sudo nixos-rebuild switch --flake .#new

echo "After reboot, run: passwd"

reboot
