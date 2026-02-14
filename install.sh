#!/bin/bash

# ===================================================================
# Installer: domainfo
# Descripción: Instalador universal (Debian/RHEL/Arch/Alpine)
# Autor: Jhon Barrera
# Agradecimientos: Gracias Mr. Anderson por tu idea de hacerlo 
#                  multiplataforma https://github.com/andersonmavi30
# ===================================================================

# Configuración de rutas
INSTALL_DIR="/usr/share/domainfo"
BIN_LINK="/usr/local/bin/domainfo"
MAN_DIR="/usr/share/man/man1"
SOURCE_FILE="domainfo.sh"
MAN_FILE="domainfo.1"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Validación de Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Error: Debes ejecutar este script como root.${NC}"
  echo -e "${YELLOW}Uso: sudo ./install.sh${NC}"
  exit 1
fi

echo -e "${GREEN}[*] Iniciando instalación de DOMAINFO v1.2...${NC}"

# 2. Función de detección e instalación de dependencias
install_deps() {
    local pkgs="whois curl"
    echo -e "${BLUE}[*] Verificando dependencias ($pkgs)...${NC}"

    # Si ya existen, saltar
    if command -v whois &> /dev/null && command -v curl &> /dev/null; then
        echo -e "${GREEN}[OK] Dependencias ya instaladas.${NC}"
        return
    fi

    # Detección del gestor de paquetes
    if command -v apt-get &> /dev/null; then
        echo -e "${YELLOW}[INFO] Detectado: APT (Debian/Ubuntu/Kali)${NC}"
        apt-get update -qq && apt-get install -y $pkgs
    elif command -v dnf &> /dev/null; then
        echo -e "${YELLOW}[INFO] Detectado: DNF (Fedora/RHEL/CentOS 8+)${NC}"
        dnf install -y $pkgs
    elif command -v yum &> /dev/null; then
        echo -e "${YELLOW}[INFO] Detectado: YUM (CentOS 7/RHEL legacy)${NC}"
        yum install -y $pkgs
    elif command -v apk &> /dev/null; then
        echo -e "${YELLOW}[INFO] Detectado: APK (Alpine Linux)${NC}"
        apk add --no-cache $pkgs
    elif command -v pacman &> /dev/null; then
        echo -e "${YELLOW}[INFO] Detectado: PACMAN (Arch Linux/Manjaro)${NC}"
        pacman -Sy --noconfirm $pkgs
    elif command -v zypper &> /dev/null; then
        echo -e "${YELLOW}[INFO] Detectado: ZYPPER (OpenSUSE)${NC}"
        zypper install -y $pkgs
    else
        echo -e "${RED}[!] Error: No se pudo detectar el gestor de paquetes.${NC}"
        echo -e "${YELLOW}Por favor instala 'whois' y 'curl' manualmente.${NC}"
        exit 1
    fi
}

# Ejecutar instalación de dependencias
install_deps

# 3. Instalación del Script Principal
echo -e "${BLUE}[*] Configurando ejecutables...${NC}"
mkdir -p "$INSTALL_DIR"

if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$SOURCE_FILE"
    ln -sf "$INSTALL_DIR/$SOURCE_FILE" "$BIN_LINK"
    echo -e "${GREEN}[OK] Binario instalado en $BIN_LINK${NC}"
else
    echo -e "${RED}[!] Error Crítico: No encuentro el archivo fuente '$SOURCE_FILE'${NC}"
    exit 1
fi

# 4. Instalación del Manual (Man Page)
if [ -f "$MAN_FILE" ]; then
    echo -e "${BLUE}[*] Instalando documentación...${NC}"
    mkdir -p "$MAN_DIR"
    cp "$MAN_FILE" "$MAN_DIR/"
    gzip -f "$MAN_DIR/$MAN_FILE"
    
    # Actualizar base de datos de man solo si mandb existe
    if command -v mandb &> /dev/null; then
        mandb -q
    fi
    echo -e "${GREEN}[OK] Manual instalado en $MAN_DIR${NC}"
else
    echo -e "${YELLOW}[!] Advertencia: No se encontró '$MAN_FILE'. Se omitió la instalación del manual.${NC}"
fi

# 5. Finalización
echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN}   ¡Instalación Completada Exitosamente!  ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "Ejecuta: ${BLUE}domainfo --help${NC} para comenzar."