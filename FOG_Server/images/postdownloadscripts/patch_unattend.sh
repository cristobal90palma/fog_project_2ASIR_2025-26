#!/bin/bash
## Script Pro: Fix de Montaje + Inyección
. /usr/share/fog/lib/funcs.sh

dots "Iniciando Post-Instalacion Pro"

# 1. Autodetección con Montaje Forzado (RW)
osdiskpart=""
for part in $(lsblk -lo NAME,TYPE | grep part | awk '{print $1}'); do
    mkdir /ntfs 2>/dev/null
    # Forzamos el montaje RW eliminando el archivo de hibernación si existe
    ntfs-3g -o remove_hiberfile,rw /dev/$part /ntfs 2>/dev/null
    
    if [[ -d "/ntfs/Windows" || -d "/ntfs/WINDOWS" ]]; then
        osdiskpart="/dev/$part"
        echo " Partición Windows detectada en /dev/$part"
        break
    fi
    umount /ntfs 2>/dev/null
done

if [ -z "$osdiskpart" ]; then
    echo " ERROR: No se encontró partición de Windows."
    sleep 5
    exit 1
fi

# 2. Configuración de rutas
src_unattend="/images/postdownloadscripts/unattend.xml"
# DESTINO: El estándar de Windows Panther es unattend.xml
dest_path="/ntfs/Windows/Panther"
dest_file="$dest_path/unattend.xml"

# 3. Copia e Inyección de datos
if [ -f "$src_unattend" ]; then
    mkdir -p "$dest_path"
    
    # Copia forzada
    cp -f "$src_unattend" "$dest_file"
    
    if [ $? -eq 0 ]; then
        # Reemplazar el ComputerName
        if [ ! -z "$hostname" ]; then
            sed -i -e "s#<ComputerName>[^<]*</ComputerName>#<ComputerName>$hostname</ComputerName>#gi" "$dest_file"
            echo " Nombre del host ($hostname) inyectado."
        fi
        echo " Archivo aplicado correctamente en $dest_file"
    else
        echo " ERROR: No se pudo escribir en el disco (Sigue en Read-Only)."
    fi
else
    echo " ERROR: No se encuentra $src_unattend en el servidor."
fi

# 4. Registro (DevicePath)
regfile="/ntfs/Windows/System32/config/SOFTWARE"
if [ -f "$regfile" ]; then
    reged -e "$regfile" >/dev/null 2>&1 <<EOFREG
ed \Microsoft\Windows\CurrentVersion\DevicePath
%SystemRoot%\inf;%SystemRoot%\DRV;C:\Drivers
q
y
EOFREG
fi

umount /ntfs
echo " Proceso finalizado exitosamente."
