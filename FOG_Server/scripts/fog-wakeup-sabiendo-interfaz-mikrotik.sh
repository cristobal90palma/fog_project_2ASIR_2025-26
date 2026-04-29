#!/bin/bash
set -euo pipefail

# --- CONFIGURACIÓN ---
DB_NAME="fog"
DB_CONF="/etc/mysql/fog_readonly.cnf"  # Tu archivo blindado
ROUTER_USER="usuario-wol"
ROUTER_IP="10.2.7.3"

# Definición manual de interfaces (ya que no hay permiso de 'read' en el router)
INTERFACES=("ether0" "ether1" "ether2" "ether3")

# --- VALIDACIÓN DE ARGUMENTOS ---
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 -h [NombreHost] o $0 -g [NombreGrupo]"
    exit 1
fi

MODE="$1"
VALUE="$2"

# Sanitización de entrada (Whitelist estricta)
if [[ ! "$VALUE" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: El nombre contiene caracteres no permitidos."
    exit 1
fi

# --- FUNCIÓN SQL SEGURA ---
get_macs() {
    local query=""
    if [ "$MODE" == "-h" ]; then
        query="SELECT m.hmMAC FROM hosts h JOIN hostMAC m ON h.hostID = m.hmHostID AND m.hmPrimary = '1' WHERE h.hostName = '${VALUE}';"
    else
        query="SELECT m.hmMAC FROM groups g JOIN groupMembers gm ON g.groupID = gm.gmGroupID JOIN hostMAC m ON gm.gmHostID = m.hmHostID AND m.hmPrimary = '1' WHERE g.groupName = '${VALUE}';"
    fi
    
    mysql --defaults-extra-file="$DB_CONF" "$DB_NAME" -N -B -e "$query"
}

# --- VALIDACIÓN FORMATO MAC ---
valid_mac() {
    [[ "$1" =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]
}

# --- PROCESO ---
MACS=$(get_macs)

if [ -z "$MACS" ]; then
    echo "No se encontraron MACs para: $VALUE"
    exit 1
fi

# Construimos la ráfaga masiva de comandos
# Este script enviará el paquete por CADA interfaz para CADA MAC en un solo viaje SSH
MIKROTIK_BATCH_CMD=""

while IFS= read -r mac; do
    [ -z "$mac" ] && continue
    
    clean_mac=$(echo "$mac" | tr '-' ':' | tr '[:lower:]' '[:upper:]')

    if valid_mac "$clean_mac"; then
        echo "Preparando ráfaga para: $clean_mac"
        # Para cada interfaz definida, añadimos el comando al lote
        for interface in "${INTERFACES[@]}"; do
            MIKROTIK_BATCH_CMD+="/tool wol mac=$clean_mac interface=$interface; "
        done
    else
        echo "Aviso: Ignorando MAC inválida: $clean_mac"
    fi
done <<< "$MACS"

# --- ENVÍO ÚNICO ---
if [ -n "$MIKROTIK_BATCH_CMD" ]; then
    echo "Iniciando ráfaga SSH hacia MikroTik ($ROUTER_IP)..."
    # BatchMode evita bloqueos por petición de password, ConnectTimeout evita cuelgues
    if ssh -o BatchMode=yes -o ConnectTimeout=10 "${ROUTER_USER}@${ROUTER_IP}" "$MIKROTIK_BATCH_CMD"; then
        echo "✅ Éxito: Todos los comandos enviados por las interfaces: ${INTERFACES[*]}"
    else
        echo "❌ Error: Falló la comunicación con el router."
        exit 1
    fi
else
    echo "No hay comandos válidos para procesar."
fi