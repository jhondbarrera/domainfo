#!/bin/bash

INSTALL_DIR="/usr/share/domainfo"
BIN_LINK="/usr/local/bin/domainfo"
MAN_FILE="/usr/share/man/man1/domainfo.1.gz"

if [ "$EUID" -ne 0 ]; then
  echo "Ejecutar como root."
  exit 1
fi

echo "[*] Desinstalando domainfo..."

rm -f "$BIN_LINK"
rm -rf "$INSTALL_DIR"
if [ -f "$MAN_FILE" ]; then
    rm -f "$MAN_FILE"
    mandb -q
fi

echo "[SUCCESS] Desinstalado correctamente."
