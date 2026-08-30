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
  fzf
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
  z
  zshrc
)

echo "==> Installing dependencies"
"$DOTFILES_DIR/install-dependencies.sh"

backup_conflicts() {
  local pkg="$1"
  local pkg_dir="$DOTFILES_DIR/$pkg"
  local rel target real_target real_file backed_up=0

  while IFS= read -r -d '' file; do
    rel="${file#"$pkg_dir"/}"
    target="$TARGET_DIR/$rel"
    real_file="$(realpath -m "$file")"

    if [ -L "$target" ] && [ ! -e "$target" ]; then
      # broken symlink -- nothing to preserve, just remove it
      rm -f "$target"
      continue
    fi

    if [ -e "$target" ]; then
      real_target="$(realpath -m "$target")"
      if [ "$real_target" = "$real_file" ]; then
        # already correctly stowed, possibly via a tree-folded parent
        # symlink -- do NOT touch it, or we'd move the repo's own file
        continue
      fi
      mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      echo "    backed up: $rel"
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

ZSH_PATH="$(command -v zsh)"
if [ -n "$ZSH_PATH" ] && [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]; then
  echo "==> Setting default shell to zsh (you'll be asked for your password)"
  chsh -s "$ZSH_PATH"
fi

echo "==> Done. Log out/in (or restart Hyprland) for all changes to take effect."
