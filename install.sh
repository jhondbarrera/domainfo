#!/bin/bash

# =========================
# Instalador DOMAINFO v1.0
# =========================

# Modo estricto: si algo falla, aborta y muestra línea
set -Eeuo pipefail
trap 'echo -e "${RED}[!] Falló en línea $LINENO. Abortando.${NC}"' ERR

# Configuración
INSTALL_DIR="/usr/share/domainfo"
BIN_LINK="/usr/local/bin/domainfo"
MAN_DIR="/usr/share/man/man1"

# Detectar carpeta real del instalador (para rutas relativas)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/domainfo.sh"
MAN_FILE="$SCRIPT_DIR/domainfo.1"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check Root
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo -e "${RED}[!] Ejecutar como root: sudo ./install.sh${NC}"
    exit 1
fi

# Instalación portable de dependencia 'whois'
install_whois() {
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y whois
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y whois
  elif command -v yum >/dev/null 2>&1; then
    yum install -y whois
  elif command -v pacman >/dev/null 2>&1; then
    pacman -Sy --noconfirm whois
  elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache whois
  else
    echo -e "${RED}[!] No encuentro un gestor de paquetes soportado para instalar 'whois'.${NC}"
    echo -e "${BLUE}[*] Instálalo manualmente e intenta de nuevo.${NC}"
    exit 1
  fi
}

echo -e "${GREEN}[*] Instalando DOMAINFO v1.0...${NC}"

# 1. Dependencias
if ! command -v whois >/dev/null 2>&1; then
  echo -e "${BLUE}[*] Instalando dependencia 'whois'...${NC}"
  install_whois
else
  echo -e "${BLUE}[*] Dependencia 'whois' ya está instalada.${NC}"
fi

# 2. Instalar Script
mkdir -p "$INSTALL_DIR"

if [ -f "$SOURCE_FILE" ]; then
  cp "$SOURCE_FILE" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/$(basename "$SOURCE_FILE")"
  ln -sf "$INSTALL_DIR/$(basename "$SOURCE_FILE")" "$BIN_LINK"
  echo -e "${BLUE}[*] Binario instalado en ${BIN_LINK}${NC}"
else
  echo -e "${RED}[!] Error: No encuentro $(basename "$SOURCE_FILE") en ${SCRIPT_DIR}${NC}"
  exit 1
fi

# 3. Instalar Manual
if [ -f "$MAN_FILE" ]; then
  mkdir -p "$MAN_DIR"
  cp "$MAN_FILE" "$MAN_DIR/"
  gzip -f "$MAN_DIR/$(basename "$MAN_FILE")"

  # mandb puede no existir en sistemas minimalistas, no fallar por eso
  if command -v mandb >/dev/null 2>&1; then
    mandb -q || true
  fi

  echo -e "${BLUE}[*] Manual instalado en ${MAN_DIR}${NC}"
else
  echo -e "${BLUE}[*] No se encontró $(basename "$MAN_FILE"), saltando instalación de manpage.${NC}"
fi

echo -e "${GREEN}[SUCCESS] Instalación completada.${NC}"
echo -e "Ejecuta: ${GREEN}domainfo --help${NC} o ${GREEN}man domainfo${NC}"
