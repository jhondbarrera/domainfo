#!/bin/bash

# Configuración
INSTALL_DIR="/usr/share/domainfo"
BIN_LINK="/usr/local/bin/domainfo"
MAN_DIR="/usr/share/man/man1"
SOURCE_FILE="domainfo.sh"
MAN_FILE="domainfo.1"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Ejecutar como root: sudo ./install.sh${NC}"
  exit 1
fi

echo -e "${GREEN}[*] Instalando DOMAINFO v1.0...${NC}"

# 1. Dependencias
if ! command -v whois &> /dev/null; then
    echo -e "${BLUE}[*] Instalando dependencia 'whois'...${NC}"
    apt-get update -qq && apt-get install -y whois
fi

# 2. Instalar Script
mkdir -p "$INSTALL_DIR"
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$SOURCE_FILE"
    ln -sf "$INSTALL_DIR/$SOURCE_FILE" "$BIN_LINK"
    echo -e "${BLUE}[*] Binario instalado en $BIN_LINK${NC}"
else
    echo -e "${RED}[!] Error: No encuentro $SOURCE_FILE${NC}"
    exit 1
fi

# 3. Instalar Manual
if [ -f "$MAN_FILE" ]; then
    mkdir -p "$MAN_DIR"
    cp "$MAN_FILE" "$MAN_DIR/"
    gzip -f "$MAN_DIR/$MAN_FILE"
    mandb -q
    echo -e "${BLUE}[*] Manual instalado en $MAN_DIR${NC}"
fi

echo -e "${GREEN}[SUCCESS] Instalación completada.${NC}"
echo -e "Ejecuta: ${GREEN}domainfo --help${NC} o ${GREEN}man domainfo${NC}"
