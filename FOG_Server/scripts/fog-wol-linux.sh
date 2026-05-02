#!/bin/bash
set -euo pipefail

DB_NAME="fog"
DB_CONF="/etc/mysql/fog_readonly.cnf"
REMOTE_LINUX="172.18.10.10"
REMOTE_USER="root"

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 -h [NombreHost] o $0 -g [NombreGrupo]"
    exit 1
fi

MODE="$1"
VALUE="$2"

if [[ ! "$VALUE" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: El nombre contiene caracteres no permitidos."
    exit 1
fi

get_macs() {
    local query=""
    if [ "$MODE" == "-h" ]; then
        query="SELECT m.hmMAC FROM hosts h JOIN hostMAC m ON h.hostID = m.hmHostID AND m.hmPrimary = '1' WHERE h.hostName = '${VALUE}';"
    else
        query="SELECT m.hmMAC FROM groups g JOIN groupMembers gm ON g.groupID = gm.gmGroupID JOIN hostMAC m ON gm.gmHostID = m.hmHostID AND m.hmPrimary = '1' WHERE g.groupName = '${VALUE}';"
    fi
    mysql --defaults-extra-file="$DB_CONF" "$DB_NAME" -N -B -e "$query"
}

valid_mac() {
    [[ "$1" =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]
}

MACS=$(get_macs)

if [ -z "$MACS" ]; then
    echo "No se encontraron direcciones MAC para esta selección: $VALUE"
    exit 1
fi

# --- Construir lista de MACs limpias, sin salto de línea final ---
declare -a MAC_ARRAY=()
while IFS= read -r mac || [ -n "$mac" ]; do
    # Eliminar \r, \n y espacios
    mac=$(echo "$mac" | tr -d '\r\n' | xargs)
    [ -z "$mac" ] && continue
    # Normalizar: guiones a dos puntos, y convertir a minúsculas (puede ser más compatible)
    clean_mac=$(echo "$mac" | tr '-' ':' | tr '[:upper:]' '[:lower:]')
    if valid_mac "$clean_mac"; then
        echo "Encolando WOL → $clean_mac"
        MAC_ARRAY+=("$clean_mac")
    else
        echo "Aviso: Ignorando dato inválido: $clean_mac"
    fi
done <<< "$MACS"

if [ ${#MAC_ARRAY[@]} -eq 0 ]; then
    echo "No hay MACs válidas para enviar."
    exit 1
fi

# Convertir array a una cadena con saltos de línea, pero sin línea vacía al final
MAC_LIST=$(printf "%s\n" "${MAC_ARRAY[@]}")

# --- Envío remoto ---
echo "Enviando tanda WOL a $REMOTE_LINUX..."

ssh -o BatchMode=yes -o ConnectTimeout=8 "${REMOTE_USER}@${REMOTE_LINUX}" \
    "INT=\$(ip route | awk '/default/ {print \$5; exit}'); \
     [ -z \"\$INT\" ] && echo 'ERROR: No se pudo determinar la interfaz' && exit 1; \
     while IFS= read -r mac; do \
         [ -z \"\$mac\" ] && continue; \
         echo '>>> Enviando WOL a '\$mac; \
         etherwake -i \"\$INT\" -b \"\$mac\" || echo '    Fallo para '\$mac; \
         sleep 0.1; \
     done" <<< "$MAC_LIST"

if [ $? -eq 0 ]; then
    echo "Éxito: Paquetes enviados correctamente al Jump Box $REMOTE_LINUX"
else
    echo "Error: No se pudo completar el envío vía SSH al Jump Box $REMOTE_LINUX"
    exit 1
fi
