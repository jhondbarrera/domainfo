# DOMAINFO

**domainfo** es una herramienta de auditoría de dominios rápida y eficiente, desarrollada para profesionales de ciberseguridad, auditores e ingenieros de red. Automatiza la consulta a IANA y servidores WHOIS específicos para obtener inteligencia precisa sobre la infraestructura de dominios.

**Versión actual:** 1.2
**Autor:** Jhon Barrera

## Características Principales

- 🚀 **Inteligente:** Consulta IANA primero para encontrar el servidor TLD exacto, evitando falsos negativos.
- 🔄 **Auto-actualizable:** Incluye un mecanismo de actualización integrado (`-upgrade`).
- ⚡ **Multi-objetivo:** Audita múltiples dominios en una sola línea de comando.
- 🐚 **Polyglot:** Compatible nativamente con **Bash** y **Zsh**.
- 📋 **Modo Lista:** Procesa auditorías masivas desde un archivo (`-L`).
- 🧹 **Salida Limpia:** Filtra el ruido del WHOIS tradicional para mostrar solo datos tácticos (Fechas, Registrar, Name Servers).

# Uso

**Ayuda:** domainfo --help.

**Dominio único:** domainfo google.com.

**Múltiples dominios:** domainfo google.com microsoft.com cisco.com

**Lista de objetivos:** domainfo -L targets.txt.

**Actualizar domainfo:** domainfo -upgrade

**Ver manual completo:** man domainfo.

## Instalación

Simplemente ejecuta el siguiente comando en tu terminal:

```bash
curl -sL https://raw.githubusercontent.com/jhondbarrera/domainfo/main/get.sh | bash
```
