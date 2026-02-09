#!/bin/bash
# Script de instalación remota para Domainfo
# Uso: curl -sL https://raw.githubusercontent.com/jhondbarrera/domainfo/main/get.sh | bash

REPO="jhondbarrera/domainfo"
BRANCH="main"
URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
TMP_DIR=$(mktemp -d)

echo -e "\033[0;34m[*] Descargando Domainfo desde GitHub...\033[0m"

# Descargar y extraer en directorio temporal
if curl -sL "$URL" | tar xz -C "$TMP_DIR"; then
    cd "$TMP_DIR/domainfo-$BRANCH"
    
    chmod +x install.sh
    sudo ./install.sh
    
    echo -e "\033[0;32m[*] Limpiando archivos temporales...\033[0m"
    rm -rf "$TMP_DIR"
else
    echo -e "\033[0;31m[!] Error al descargar el repositorio.\033[0m"
    rm -rf "$TMP_DIR"
    exit 1
fi
