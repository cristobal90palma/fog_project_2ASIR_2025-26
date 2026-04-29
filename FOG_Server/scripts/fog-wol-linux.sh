#!/bin/bash
# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3799230
# set -e: Detiene el script si un comando falla.
# set -u: Lanza un error si se intenta usar una variable no definida.
# set -o pipefail: Devuelve el código de error del último comando de una tubería que haya fallado.
set -euo pipefail

# Definición de variables globales para la base de datos de FOG y el Jump Box SSH
DB_NAME="fog"
DB_CONF="/etc/mysql/fog_readonly.cnf"  # Archivo de solo lectura con nuestras credenciales
REMOTE_LINUX="172.18.10.10"
REMOTE_USER="root"

# --- VALIDACIÓN DE ARGUMENTOS ---
# Comprueba que el usuario haya pasado exactamente 2 argumentos (-h/-g y el nombre)
# https://earthly.dev/blog/bash-conditionals/#:~:text=%2Dne%20:%20checks%20if%20two%20values/variables%20are%20not%20equal%20(%20!%20=%20)
# https://askubuntu.com/questions/939620/what-does-mean-in-bash
# En Bash, $# es una variable especial que representa el número total de argumentos posicionales (parámetros) pasados a un script o función, excluyendo el nombre del script en sí ($0)
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 -h [NombreHost] o $0 -g [NombreGrupo]"
    exit 1
fi

# https://www.reddit.com/r/bash/comments/hui3hd/i_dont_understand_0_1_2_variable_in_bash_shell/?tl=es-es
MODE="$1" # El modo de selección: -h (host) o -g (grupo)
VALUE="$2" # El nombre específico del host o grupo

# Sanitización de entrada: Solo permite letras, números y caracteres básicos
# para prevenir ataques de inyección de código o SQL.
if [[ ! "$VALUE" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: El nombre contiene caracteres no permitidos."
    exit 1
fi

# --- FUNCIÓN SQL SEGURA ---
# Obtiene las direcciones MAC primarias de la base de datos basándose en el modo elegido.
get_macs() {
    local query=""
    if [ "$MODE" == "-h" ]; then
    # Query para buscar por nombre de host individual
        query="SELECT m.hmMAC FROM hosts h JOIN hostMAC m ON h.hostID = m.hmHostID AND m.hmPrimary = '1' WHERE h.hostName = '${VALUE}';"
    else
    # Query para buscar por nombre de grupo (une tablas de grupos y miembros)
        query="SELECT m.hmMAC FROM groups g JOIN groupMembers gm ON g.groupID = gm.gmGroupID JOIN hostMAC m ON gm.gmHostID = m.hmHostID AND m.hmPrimary = '1' WHERE g.groupName = '${VALUE}';"
    fi
    
    # Ejecuta mysql usando el archivo de configuración para no exponer credenciales en el comando
    # -N: No imprime encabezados. -B: Formato batch (sin tablas visuales). -e: ejecutar el Query.
    mysql --defaults-extra-file="$DB_CONF" "$DB_NAME" -N -B -e "$query"
}

# --- VALIDACIÓN FORMATO MAC ---
# Expresión regular para verificar que la MAC sea válida (XX:XX:XX:XX:XX:XX)
# https://unix.stackexchange.com/questions/340440/bash-test-what-does-do
valid_mac() {
    [[ "$1" =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]
}

# --- PROCESO ---
# Llamada a la función para obtener el listado de MACs
MACS=$(get_macs)

# Si el resultado de la consulta SQL está vacío, termina el script
if [ -z "$MACS" ]; then
    echo "No se encontraron direcciones MAC para esta selección: $VALUE"
    exit 1
fi

# Construimos el lote de comandos para enviar en una sola conexión SSH
    # Esta línea se ejecutará EN EL SERVIDOR REMOTO ($REMOTE_LINUX):
    # 1. Busca la interfaz de red por defecto (donde apunta el gateway).
    # 2. Si no encuentra interfaz, detiene el proceso (exit 1).
REMOTE_BATCH_SCRIPT="INT=\$(ip route | awk '/default/ {print \$5; exit}'); [ -z \"\$INT\" ] && exit 1; "

# Bucle para procesar cada MAC encontrada
while IFS= read -r mac; do
    [ -z "$mac" ] && continue
    
    # Normalización: Convierte guiones (-) en dos puntos (:) y todo a mayúsculas. Necesario para el router Mikrotik.
    # Esto es crítico porque MikroTik es estricto con el formato de la MAC.
    clean_mac=$(echo "$mac" | tr '-' ':' | tr '[:lower:]' '[:upper:]')

    if valid_mac "$clean_mac"; then
        echo "Encolando WOL → $clean_mac"
    # Añade el comando 'etherwake' a la cadena que se enviará por SSH
    # Se usa la interfaz detectada automáticamente ($INT)
        REMOTE_BATCH_SCRIPT+="etherwake -i \"\$INT\" \"$clean_mac\"; "
    else
        echo "Aviso: Ignorando dato inválido: $clean_mac"
    fi
done <<< "$MACS"

# --- ENVÍO ÚNICO ---
# Se conecta una sola vez por SSH y ejecuta toda la cadena de comandos REMOTE_BATCH_SCRIPT
# BatchMode=yes evita que el script se quede colgado pidiendo contraseñas interactivamente
echo "Enviando tanda WOL a $REMOTE_LINUX..."
if ssh -o BatchMode=yes -o ConnectTimeout=8 "${REMOTE_USER}@${REMOTE_LINUX}" "$REMOTE_BATCH_SCRIPT"; then
    echo "Éxito: Paquetes enviados correctamente al Jump Box $REMOTE_LINUX"
else
    echo "Error: No se pudo completar el envío vía SSH al Jump Box $REMOTE_LINUX"
    exit 1
fi