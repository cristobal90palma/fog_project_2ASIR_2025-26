#!/bin/bash
# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3799230
# set -e: Detiene el script si un comando falla.
# set -u: Lanza un error si se intenta usar una variable no definida.
# set -o pipefail: Devuelve el código de error del último comando de una tubería que haya fallado.
set -euo pipefail

# Definición de variables globales para la base de datos de FOG y el Jump Box SSH
DB_NAME="fog"
DB_CONF="/etc/mysql/fog_readonly.cnf"
REMOTE_LINUX="172.18.10.10"
REMOTE_USER="root"

#  Para validar los ARGUMENTOS que se pasan antes
# Comprueba que el usuario haya pasado exactamente 2 argumentos (-h/-g y el nombre)
# https://earthly.dev/blog/bash-conditionals/#:~:text=%2Dne%20:%20checks%20if%20two%20values/variables%20are%20not%20equal%20(%20!%20=%20)
# https://askubuntu.com/questions/939620/what-does-mean-in-bash
# En Bash, $# es una variable especial que representa el número total de argumentos posicionales (parámetros) pasados a un script o función, excluyendo el nombre del script en sí ($0)
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 -h [NombreHost] o $0 -g [NombreGrupo]"
    exit 1
fi

# https://www.reddit.com/r/bash/comments/hui3hd/i_dont_understand_0_1_2_variable_in_bash_shell/?tl=es-es
MODE="$1"
VALUE="$2"

# Sanitización de entrada: Permitir letras, números, puntos, guiones bajos, guiones y espacios.
# Importante: El guion (-) debe ir al principio o al final dentro de [] para no crear rangos inválidos.
if [[ ! "$VALUE" =~ ^[a-zA-Z0-9._[:space:]-]+$ ]]; then
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

# --- Construir lista de MACs limpias, sin salto de línea final ---
# Crea un array vacío llamado MAC_ARRAY para ir guardando las MACs válidas.
declare -a MAC_ARRAY=()

# Lee el texto línea por línea.
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

# Envío al Jump Box
echo "Enviando tanda WOL a $REMOTE_LINUX..."

# Ejecución del comando SSH
ssh -o BatchMode=yes -o ConnectTimeout=8 "${REMOTE_USER}@${REMOTE_LINUX}" \
    "INT=\$(ip route | awk '/default/ {print \$5; exit}'); \
     [ -z \"\$INT\" ] && echo 'ERROR: No se pudo determinar la interfaz' && exit 1; \
     while IFS= read -r mac; do \
         [ -z \"\$mac\" ] && continue; \
         echo '>>> Enviando WOL a '\$mac; \
         etherwake -i \"\$INT\" -b \"\$mac\" || echo '    Fallo para '\$mac; \
         sleep 0.1; \
     done" <<< "$MAC_LIST"

# $?: Es una variable especial de Bash que guarda el resultado del último comando ejecutado (en este caso, el bloque de ssh).
# Si el resultado es 0, significa "todo salió bien". Si es cualquier otro número, significa que hubo un error.
if [ $? -eq 0 ]; then
    echo "Éxito: Paquetes enviados correctamente al Jump Box $REMOTE_LINUX"
else
    echo "Error: No se pudo completar el envío vía SSH al Jump Box $REMOTE_LINUX"
    exit 1
fi
