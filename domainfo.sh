#!/bin/bash

# =================================================================
# Tool: domainfo
# Descripción: Auditoría rápida de información de dominios (WHOIS/IANA).
# Compatibilidad: Bash & Zsh
# Autor: Jhon Barrera
# Versión: 1.1
# =================================================================

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
    echo -e "        v1.1 - By Jhon Barrera"
    echo -e "${NC}"
}

show_help() {
    banner
    echo -e "Uso: domainfo [OPCIÓN] [OBJETIVO]"
    echo -e "\nDescripción:"
    echo -e "  Herramienta de auditoría para obtener información de registro de dominios."
    echo -e "  Consulta IANA para determinar el servidor WHOIS correcto y extrae datos clave."
    echo -e "\nOpciones:"
    echo -e "  -h, --help      Muestra este mensaje de ayuda y sale."
    echo -e "  -L <archivo>    Procesa una lista de dominios desde un archivo de texto."
    echo -e "  <dominio>       Audita un dominio específico (ej: google.com)."
    echo -e "\nEjemplos:"
    echo -e "  domainfo google.com"
    echo -e "  domainfo -L targets.txt"
    echo -e "\nAutor: Jhon Barrera"
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
            # #Limpiar URL de la ICANN
            # val=$(echo "$val" | xargs)
            # val=${val%% http*}

            case "$(echo "$key" | tr '[:upper:]' '[:lower:]')" in
                *"domain name"*)      label="Dominio" ;;
                *"creation date"*)    label="Fecha creación" ;;
                *"expiry date"*)      label="Expira el" ;;
                *"registrar"*)        label="Registrador" ;;
                *"status"*)           label="Estado" ;;
                *"name server"*)      label="Name Server" ;;
                *) label="$key" ;; # Si algo no coincide, muestra el original
            esac

            # 4. Imprimir en formato tabla (Columna 1: 25 chars, Columna 2: Resto)
            printf "%-25s %s\n" "$label:" "$val"
        done
        echo -e "==================================================================\n"
    else
        echo -e "${RED}[!] Error: No se encontró servidor WHOIS para $t.${NC}"
    fi
}

# Argumentos
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -L)
        list_file="$2"
        if [[ -f "$list_file" ]]; then
            banner
            echo -e "${BLUE}[INFO] Procesando lista: $list_file${NC}"
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Limpieza y validación
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
        printf "${YELLOW}Escribe el dominio a auditar: ${NC}"
        read -r d
        [[ -z "$d" ]] && exit 1
        domainfo "$d"
        ;;
    *)
        banner
        domainfo "$1"
        ;;
esac