#!/usr/bin/env bash
# One-shot bootstrap for a brand-new machine: clones this repo (if not
# already present) and runs its installer. Safe to re-run.
#
#   curl -fsSL https://raw.githubusercontent.com/MaximeBonnin/dotfiles/master/bootstrap.sh | bash
set -euo pipefail

REPO_URL="https://github.com/MaximeBonnin/dotfiles.git"
DOTFILES_DIR="$HOME/.config/dotfiles"

if ! command -v git >/dev/null 2>&1; then
  echo "==> git not found, installing it (requires sudo)"
  sudo pacman -S --needed git
fi

if [ -d "$DOTFILES_DIR/.git" ]; then
  echo "==> Dotfiles already cloned at $DOTFILES_DIR, pulling latest"
  git -C "$DOTFILES_DIR" pull
else
  echo "==> Cloning dotfiles into $DOTFILES_DIR"
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

exec "$DOTFILES_DIR/install.sh"
