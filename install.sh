#!/bin/bash
# study_alarm — install script for macOS
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/Library/Application Support/study_alarm"
BIN_DIR="$HOME/bin"
LINK="$BIN_DIR/study_alarm"

echo "study_alarm kurulumu"
echo "-------------------"

command -v python3 >/dev/null 2>&1 || {
    echo "HATA: Python 3 bulunamadı. macOS'ta varsayılan gelir, xcode-select --install yapın."
    exit 1
}

if [ ! -f "$SCRIPT_DIR/study_alarm" ] || [ ! -f "$SCRIPT_DIR/alarm.py" ] || [ ! -f "$SCRIPT_DIR/alarm.html" ]; then
    echo "HATA: Gerekli dosyalar eksik. Bu script'i 'çalışma alarmı' klasörü içinden çalıştırın."
    exit 1
fi

mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/study_alarm" "$INSTALL_DIR/study_alarm"
cp "$SCRIPT_DIR/alarm.py"    "$INSTALL_DIR/alarm.py"
cp "$SCRIPT_DIR/alarm.html"  "$INSTALL_DIR/alarm.html"
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
echo "Not: gönderilen 'çalışma alarmı' klasörünü artık silebilirsin."
echo "     Program $INSTALL_DIR konumuna kopyalandı."
