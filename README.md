# DOMAINFO

**domainfo** es una herramienta de auditoría de dominios rápida y eficiente, desarrollada para profesionales de ciberseguridad. Automatiza la consulta a IANA y servidores WHOIS específicos.

**Autor:** Jhon Barrera

## Características
- 🚀 **Inteligente:** Consulta IANA primero para encontrar el servidor TLD exacto.
- 🐚 **Polyglot:** Compatible nativamente con **Bash** y **Zsh**.
- 📋 **Modo Lista:** Audita múltiples objetivos desde un archivo (`-L`).
- 🧹 **Limpio:** Filtra la salida para mostrar solo lo importante (Fechas, Registrar, Name Servers).

## Instalación

```bash
git clone [https://github.com/jhondbarrera/domainfo.git](https://github.com/jhondbarrera/domainfo.git)
cd domainfo
sudo ./install.sh

# Ayuda
domainfo --help

# Dominio único
domainfo google.com

# Lista de objetivos
domainfo -L targets.txt

# Ver manual completo
man domainfo
