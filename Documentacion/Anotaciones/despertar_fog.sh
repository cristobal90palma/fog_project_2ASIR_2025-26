#!/bin/bash

# --- CONFIGURACIÓN ---
ROUTER_USER="usuario-wol"
ROUTER_IP="10.2.7.3"
# Lista las interfaces por las que quieres que salga el WoL (separadas por espacio)
INTERFACES=("ether1" "ether2" "bridge")

# --- EXTRACCIÓN DE MACS DESDE FOG ---
# Este comando saca todas las MACs de la base de datos de FOG
# Nota: Si tu DB tiene contraseña, añádela tras -p
MACS=$(mysql -u root fog -e "SELECT hostMAC FROM hosts" -B -N)

if [ -z "$MACS" ]; then
    echo "No se encontraron MACs en la base de datos de FOG."
    exit 1
fi

echo "Iniciando encendido masivo..."

# --- BUCLE DE ENVÍO ---
for mac_raw in $MACS; do
    # FOG a veces guarda las MACs con guiones (00-11-22), MikroTik las quiere con puntos (00:11:22)
    mac=$(echo $mac_raw | tr '-' ':')
    
    echo "Despertando a $mac..."
    
    # Construimos el comando para varias interfaces: /tool wol mac=... interface=eth1; /tool wol ...
    CMD=""
    for IFACE in "${INTERFACES[@]}"; do
        CMD+="/tool wol mac=$mac interface=$IFACE; "
    done
    
    # Enviamos el comando por SSH (una sola conexión por cada PC)
    ssh $ROUTER_USER@$ROUTER_IP "$CMD"
done

echo "Proceso finalizado."
