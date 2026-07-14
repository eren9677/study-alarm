#!/bin/bash
# study_alarm — install script for macOS
set -e

INSTALL_DIR="$HOME/Library/Application Support/study_alarm"
BIN_DIR="$HOME/bin"
LINK="$BIN_DIR/study_alarm"
REPO="https://raw.githubusercontent.com/eren9677/study-alarm/master"

echo "study_alarm kurulumu"
echo "-------------------"

command -v python3 >/dev/null 2>&1 || {
    echo "HATA: Python 3 bulunamadı. macOS'ta varsayılan gelir, xcode-select --install yapın."
    exit 1
}

mkdir -p "$INSTALL_DIR"
curl -fsSL "$REPO/study_alarm"  -o "$INSTALL_DIR/study_alarm"
curl -fsSL "$REPO/alarm.py"     -o "$INSTALL_DIR/alarm.py"
curl -fsSL "$REPO/alarm.html"   -o "$INSTALL_DIR/alarm.html"
chmod +x "$INSTALL_DIR/study_alarm"

mkdir -p "$BIN_DIR"
rm -f "$LINK"
ln -s "$INSTALL_DIR/study_alarm" "$LINK"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    SHELL_RC=""
    case "$SHELL" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bash_profile" ;;
        *)      SHELL_RC="$HOME/.profile" ;;
    esac
    echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$SHELL_RC"
    echo "PATH'a ~/bin eklendi ($SHELL_RC). Yeni terminal açın veya 'source $SHELL_RC' yapın."
fi

echo ""
echo "Kurulum tamam."
echo "Yeni terminal açıp 'study_alarm --help' yazarak test edebilirsin."
echo ""
echo "Program $INSTALL_DIR konumuna kuruldu."
echo "Kaldırmak için: study_alarm --uninstall"
