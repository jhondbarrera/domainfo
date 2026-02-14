#!/bin/bash

# =================================================================
# Tool: domainfo
# Descripción: Auditoría rápida de información de dominios (WHOIS/IANA).
# Compatibilidad: Bash & Zsh
# Autor: Jhon Barrera
# Versión: 1.2 (Soporte multi-dominio en línea y actualizacion)
# =================================================================

# Configuración del Repositorio
REPO_URL="https://raw.githubusercontent.com/jhondbarrera/domainfo/main/domainfo.sh"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

banner() {
    echo -e "${BLUE}"
    cat << "EOF"
    ____                        _        ____    
   / __ \____  ____ ___  ____ _(_)____  / __/___ 
  / / / / __ \/ __ `__ \/ __ `/ / __ \ / /_/ __ \
 / /_/ / /_/ / / / / / / /_/ / / / / // __/ /_/ /
/_____/\____/_/ /_/ /_/\__,_/_/_/ /_//_/  \____/ 
                                                 
EOF
    echo -e "        v1.2 - By Jhon Barrera"
    echo -e "${NC}"
}

show_help() {
    banner
    echo -e "Uso: domainfo [OPCIÓN] [DOMINIO_1] [DOMINIO_2]..."
    echo -e "\nDescripción:"
    echo -e "  Herramienta de auditoría para obtener información de registro de dominios."
    echo -e "  Consulta IANA para determinar el servidor WHOIS correcto y extrae datos clave."
    echo -e "\nOpciones:"
    echo -e "  -h, --help      Muestra este mensaje de ayuda y sale."
    echo -e "  -upgrade        Actualiza la herramienta a la última versión disponible."
    echo -e "  -L <archivo>    Procesa una lista de dominios desde un archivo de texto."
    echo -e "\nEjemplos:"
    echo -e "  domainfo google.com"
    echo -e "  domainfo google.com hotmail.com chatgpt.com"
    echo -e "  domainfo -L targets.txt"
    echo -e "  domainfo -upgrade"
    echo -e "\nAutor: Jhon Barrera"
}

update_tool() {
    echo -e "${YELLOW}[*] Iniciando proceso de actualización...${NC}"
    SCRIPT_PATH=$(realpath "$0")
    TEMP_FILE="/tmp/domainfo_update"

    if [ ! -w "$SCRIPT_PATH" ]; then
        echo -e "${RED}[!] Error: No tienes permisos de escritura en $SCRIPT_PATH.${NC}"
        echo -e "${YELLOW}[*] Por favor ejecuta: sudo domainfo -upgrade${NC}"
        exit 1
    fi

    echo -e "${BLUE}[INFO] Descargando última versión desde GitHub...${NC}"
    if curl -sL "$REPO_URL" -o "$TEMP_FILE"; then
        if grep -q "#!/bin/bash" "$TEMP_FILE"; then
            mv "$TEMP_FILE" "$SCRIPT_PATH"
            chmod +x "$SCRIPT_PATH"
            echo -e "${GREEN}[SUCCESS] ¡Actualización completada!${NC}"
            exit 0
        else
            echo -e "${RED}[!] Error: El archivo descargado parece corrupto.${NC}"
            rm -f "$TEMP_FILE"
            exit 1
        fi
    else
        echo -e "${RED}[!] Error: Falló la conexión con el repositorio.${NC}"
        exit 1
    fi
}

domainfo() {
    local d="$1"
    [ -z "$d" ] && return
    
    local t=".${d##*.}"
    local s
    
    echo -e "${YELLOW}[*] Buscando servidor WHOIS para TLD: ${t}${NC}"
    
    # Consulta a IANA para obtener el servidor correcto
    s=$(whois -h whois.iana.org "$t" | grep -i "whois:" | awk '{print $2}' | head -n 1)

    if [[ -n "$s" ]]; then
        echo -e "${GREEN}[+] Servidor encontrado: ${s}${NC}"
        echo -e "\n=================================================================="
        printf "${CYAN}%-25s %-40s${NC}\n" "PARAMETRO" "VALOR"
        echo -e "=================================================================="

        whois -h "$s" "$d" | grep -iE "Domain Name:|Creation Date:|Registry Expiry Date:|Registrar:|Status:|Name Server:" | while IFS=':' read -r key val; do
            val=$(echo "$val" | xargs)
            val=${val%% http*} 

            case "$(echo "$key" | tr '[:upper:]' '[:lower:]')" in
                *"domain name"*)      label="Dominio" ;;
                *"creation date"*)    label="Fecha creación" ;;
                *"expiry date"*)      label="Expira el" ;;
                *"registrar"*)        label="Registrador" ;;
                *"status"*)           label="Estado" ;;
                *"name server"*)      label="Name Server" ;;
                *) label="$key" ;; 
            esac

            printf "%-25s %s\n" "$label:" "$val"
        done
        echo -e "==================================================================\n"
    else
        echo -e "${RED}[!] Error: No se encontró servidor WHOIS para $t.${NC}"
    fi
}

# Lógica principal
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -upgrade|--upgrade)
        update_tool
        exit 0
        ;;
    -L)
        list_file="$2"
        if [[ -f "$list_file" ]]; then
            banner
            echo -e "${BLUE}[INFO] Procesando lista: $list_file${NC}"
            while IFS= read -r line || [[ -n "$line" ]]; do
                line=$(echo "$line" | xargs)
                [[ -z "$line" || "$line" =~ ^# ]] && continue
                echo -e "\n${BLUE}>>> Auditando: $line${NC}"
                domainfo "$line"
            done < "$list_file"
        else
            echo -e "${RED}[!] Error: Archivo '$list_file' no existe.${NC}"
            exit 1
        fi
        ;;
    "")
        banner
        printf "${YELLOW}Escribe el dominio (o dominios) a auditar: ${NC}"
        read -r input_domains
        [[ -z "$input_domains" ]] && exit 1
        for d in $input_domains; do
             echo -e "\n${BLUE}>>> Auditando: $d${NC}"
             domainfo "$d"
        done
        ;;
    *)
        banner
        for domain in "$@"; do
            echo -e "\n${BLUE}>>> Auditando: $domain${NC}"
            domainfo "$domain"
        done
        ;;
esac