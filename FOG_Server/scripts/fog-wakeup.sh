#!/bin/bash

# --- Configuración de credenciales---
DB_USER="root"
DB_PASS="" # Pon la contraseña si tiene
ROUTER_USER="usuario-wol"
ROUTER_IP="10.2.7.3"

# https://www.reddit.com/r/bash/comments/hui3hd/i_dont_understand_0_1_2_variable_in_bash_shell/?tl=es-es


# --- Funciones SQL para conseguir las MAC ---
# $1 aquí representa el primer argumento enviado a la FUNCIÓN (Nombre del Host).
get_macs_by_host() {
    mysql -u$DB_USER -p$DB_PASS fog -N -B -e "SELECT m.hmMAC FROM hosts h JOIN hostMAC m ON h.hostID = m.hmHostID AND m.hmPrimary = '1' WHERE h.hostName = '$1';"
}

# $1 aquí representa el nombre del grupo pasado a la función.
get_macs_by_group() {
    mysql -u$DB_USER -p$DB_PASS fog -N -B -e "SELECT m.hmMAC FROM groups g JOIN groupMembers gm ON g.groupID = gm.gmGroupID JOIN hostMAC m ON gm.gmHostID = m.hmHostID AND m.hmPrimary = '1' WHERE g.groupName = '$1';"
}

# --- Ejecución: Case para hosts "h" o grupos "h". Si no pones nada válido, te muestra cómo usar el script y se detiene.
# --- Si no encuentra MACs se indica.
# $0: Nombre del script | $1: Primer argumento (-h o -g) | $2: Segundo argumento (Valor)
case $1 in
    -h) MACS=$(get_macs_by_host "$2") ;;
    -g) MACS=$(get_macs_by_group "$2") ;;
    *) echo "Uso: $0 -h [NombreHost] o $0 -g [NombreGrupo]"; exit 1 ;;
esac

if [ -z "$MACS" ]; then
    echo "No se encontraron MACs para la selección."
    exit 1
fi

# --- ENVÍO AL MIKROTIK ---
for mac in $MACS; do
    # NORMALIZACIÓN DE MAC:
    # 1. Cambia guiones por dos puntos (tr '-' ':')
    # 2. Convierte minúsculas a mayúsculas (tr '[:lower:]' '[:upper:]')
    # Esto es necesario porque MikroTik no acepta formatos como 00-aa-11.
    # https://stackoverflow.com/questions/23178769/unix-tr-command-to-convert-lower-case-to-upper-and-upper-to-lower-case
    clean_mac=$(echo $mac | tr '-' ':' | tr '[:lower:]' '[:upper:]')
    echo "Enviando comando WOL para: $clean_mac"

    # SCRIPT INTERNO MIKROTIK (RouterOS):
    # Recorre todas las interfaces activas (running=yes) y envía el paquete WOL.
    MIKROTIK_CMD=":foreach i in=[/interface find where running=yes] do={ /tool wol mac=$clean_mac interface=[/interface get \$i name] }"

    # Ejecución vía SSH. En nuestro caso tenemos configurado la Clave Pública con el router
    ssh $ROUTER_USER@$ROUTER_IP "$MIKROTIK_CMD"
done
