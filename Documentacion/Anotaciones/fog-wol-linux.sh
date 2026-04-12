#!/bin/bash

# --- CONFIGURACIÓN ---
DB_USER="root"
DB_PASS="" 
REMOTE_LINUX="172.18.10.10" # <--- IP del proxy-WOL

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
    echo "No se encontraron MACs."
    exit 1
fi

# --- ENVÍO AL CONTENEDOR ---
for mac in $MACS; do
    clean_mac=$(echo $mac | tr '-' ':' | tr '[:upper:]' '[:lower:]')
    echo "Despertando a $clean_mac vía $REMOTE_LINUX..."

    # Comando inteligente: detecta la interfaz activa y lanza etherwake
    # Usamos \$ para que el contenedor interprete la variable, no el servidor FOG
    REMOTE_CMD="INT=\$(ip -o link show | grep 'state UP' | awk -F': ' '{print \$2}' | cut -d'@' -f1 | head -n1); etherwake -i \$INT $clean_mac"

    ssh root@$REMOTE_LINUX "$REMOTE_CMD"
done