#!/bin/bash

# --- CONFIGURACIÓN ---
DB_USER="root"
DB_PASS="" # Pon la contraseña si tiene
ROUTER_USER="usuario-wol"
ROUTER_IP="10.2.7.3"

# --- FUNCIONES DE CONSULTA SQL ---
get_macs_by_host() {
    mysql -u$DB_USER -p$DB_PASS fog -N -B -e "SELECT m.hmMAC FROM hosts h JOIN hostMAC m ON h.hostID = m.hmHostID AND m.hmPrimary = '1' WHERE h.hostName = '$1';"
}

get_macs_by_group() {
    mysql -u$DB_USER -p$DB_PASS fog -N -B -e "SELECT m.hmMAC FROM groups g JOIN groupMembers gm ON g.groupID = gm.gmGroupID JOIN hostMAC m ON gm.gmHostID = m.hmHostID AND m.hmPrimary = '1' WHERE g.groupName = '$1';"
}

# --- LÓGICA DE EJECUCIÓN ---
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
    # Limpiar formato de MAC (Asegurar mayúsculas y dos puntos)
    clean_mac=$(echo $mac | tr '-' ':' | tr '[:lower:]' '[:upper:]')
    echo "Enviando comando WOL para: $clean_mac"

    # Comando dinámico que se ejecuta íntegramente en el MikroTik
    # Nota: Escapamos el $ de $i para que Bash no lo procese
    MIKROTIK_CMD=":foreach i in=[/interface find where running=yes] do={ /tool wol mac=$clean_mac interface=[/interface get \$i name] }"

    # Ejecución vía SSH
    ssh $ROUTER_USER@$ROUTER_IP "$MIKROTIK_CMD"
done