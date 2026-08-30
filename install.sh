#!/usr/bin/env bash
# Installs these dotfiles into $HOME using GNU Stow.
# Any real (non-symlink) file that would be overwritten is moved into a
# timestamped backup directory first, so nothing is ever destroyed.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

PACKAGES=(
  alacritty
  backgrounds
  gtk
  hyprland
  hyprpaper
  kitty
  nvim
  scripts
  swaync
  waybar
  wofi
  wpaperd
  zshrc
)

if ! command -v stow >/dev/null 2>&1; then
  echo "==> GNU Stow not found, installing it (requires sudo)"
  sudo pacman -S --needed stow
fi

backup_conflicts() {
  local pkg="$1"
  local pkg_dir="$DOTFILES_DIR/$pkg"
  local rel target backed_up=0

  while IFS= read -r -d '' file; do
    rel="${file#"$pkg_dir"/}"
    target="$TARGET_DIR/$rel"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      echo "    backed up: $rel"
      backed_up=1
    elif [ -L "$target" ] && [ "$(readlink -f "$target")" != "$(readlink -f "$file")" ]; then
      mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      echo "    backed up (stale symlink): $rel"
      backed_up=1
    fi
  done < <(find "$pkg_dir" -type f -print0)

  [ "$backed_up" = 1 ]
}

echo "==> Installing dotfiles from $DOTFILES_DIR into $TARGET_DIR"

for pkg in "${PACKAGES[@]}"; do
  echo "--> $pkg"
  if backup_conflicts "$pkg"; then
    echo "    (existing files for $pkg backed up to $BACKUP_DIR)"
  fi
  stow --restow --dir "$DOTFILES_DIR" --target "$TARGET_DIR" "$pkg"
done

if [ -d "$BACKUP_DIR" ]; then
  echo "==> Pre-existing configs backed up to: $BACKUP_DIR"
fi

echo "==> Done. Log out/in (or restart Hyprland) for all changes to take effect."
