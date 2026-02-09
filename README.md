# DOMAINFO

**domainfo** es una herramienta de auditoría de dominios rápida y eficiente, desarrollada para profesionales de ciberseguridad. Automatiza la consulta a IANA y servidores WHOIS específicos.

**Autor:** Jhon Barrera

## Características
- 🚀 **Inteligente:** Consulta IANA primero para encontrar el servidor TLD exacto.
- 🐚 **Polyglot:** Compatible nativamente con **Bash** y **Zsh**.
- 📋 **Modo Lista:** Audita múltiples objetivos desde un archivo (`-L`).
- 🧹 **Limpio:** Filtra la salida para mostrar solo lo importante (Fechas, Registrar, Name Servers).

# Uso

**Ayuda:** domainfo --help.

**Dominio único:** domainfo google.com.

**Lista de objetivos:** domainfo -L targets.txt.

**Ver manual completo:** man domainfo.

## Instalación

Simplemente ejecuta el siguiente comando en tu terminal:

```bash
curl -sL [https://raw.githubusercontent.com/jhondbarrera/domainfo/main/get.sh](https://raw.githubusercontent.com/jhondbarrera/domainfo/main/get.sh) | bash
