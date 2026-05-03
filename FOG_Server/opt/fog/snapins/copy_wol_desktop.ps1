# Definir origen (el archivo que FOG descarga en la carpeta temporal)
$sourcePath = Join-Path -Path $PSScriptRoot -ChildPath "WakeOnLanMonitor.exe"

# Opción A: Escritorio Público (Recomendado para FOG)
# Esto hace que el icono aparezca en el escritorio de cualquier usuario que inicie sesión.
$destinationPath = "C:\Users\Public\Desktop\WakeOnLanMonitor.exe"

# Verificar si el origen existe antes de copiar
if (Test-Path $sourcePath) {
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force -ErrorAction SilentlyContinue
} else {
    Write-Error "No se encontró el archivo de origen en $sourcePath"
    exit 1
}