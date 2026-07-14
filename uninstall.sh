#!/bin/bash
# study_alarm — uninstall script for macOS
set -e

INSTALL_DIR="$HOME/Library/Application Support/study_alarm"
BIN_DIR="$HOME/bin"
LINK="$BIN_DIR/study_alarm"

echo "study_alarm kaldırılıyor..."

[ -L "$LINK" ] && rm -f "$LINK" && echo "Symlink silindi: $LINK"
[ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR" && echo "Dosyalar silindi: $INSTALL_DIR"

echo "Kaldırma tamam."
