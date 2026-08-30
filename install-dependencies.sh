#!/usr/bin/env bash
# Installs every program these dotfiles (and the tools you actually use)
# depend on. Lists every package unconditionally, including ones you may
# already have -- `pacman -S --needed` silently skips anything installed,
# so this is safe and idempotent to rerun after any fresh install.
set -euo pipefail

# --- core / shell tooling -------------------------------------------------
CORE=(
  git
  github-cli     # gh
  stow
  x11-ssh-askpass  # ssh-askpass, needed for GUI passphrase prompts (e.g. VS Code, git GUI push)
)

# --- terminal & editor -----------------------------------------------------
TERMINAL_EDITOR=(
  kitty
  alacritty
  neovim
  tmux           # required by vim-test/vimux and vim-tmux-navigator
  lazygit        # used by snacks.nvim's <leader>lg/<leader>gl
  ripgrep        # used by telescope/snacks picker
  fd
)

# --- Hyprland desktop stack (from hyprland.lua / waybar / swaync) ---------
DESKTOP=(
  hyprland
  waybar
  wofi           # $menu in hyprland.lua
  swaync         # notification center, exec-once'd
  wpaperd        # wallpaper daemon, exec-once'd
  hyprshot       # bound to Print / SHIFT+Print
  playerctl      # media keys
  blueman        # blueman-manager, waybar bluetooth on-click
  nautilus       # $fileManager in hyprland.lua
  brightnessctl  # brightness keys
  power-profiles-daemon  # powerprofilesctl, swaync toggle
  pavucontrol
  pipewire-pulse
  wireplumber    # wpctl
  bluez
  bluez-utils    # bluetoothctl, used by bt-autoconnect
)

# --- toolchains needed by Neovim plugins/LSPs, plus general dev languages -
DEV_TOOLCHAINS=(
  base-devel     # gcc/make, needed to build treesitter parsers
  nodejs
  npm            # mason LSP servers (tailwindcss-language-server), swagger-ui-watcher
  ruby           # ruby_lsp
  rust           # cargo, needed by avante.nvim's `make` build
  python-pip
  go
  jdk21-openjdk
)

# --- everyday apps (kept here even though most are already installed) -----
APPS=(
  code
  intellij-idea-community-edition
  discord
  spotify-launcher
)

ALL_PACKAGES=(
  "${CORE[@]}"
  "${TERMINAL_EDITOR[@]}"
  "${DESKTOP[@]}"
  "${DEV_TOOLCHAINS[@]}"
  "${APPS[@]}"
)

echo "==> Installing ${#ALL_PACKAGES[@]} packages (already-installed ones are skipped automatically)"
sudo pacman -S --needed "${ALL_PACKAGES[@]}"

echo "==> Done."
