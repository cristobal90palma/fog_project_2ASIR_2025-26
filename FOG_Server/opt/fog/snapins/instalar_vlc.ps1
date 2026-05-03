# 1. Instalar VLC usando Chocolatey de forma silenciosa
# El parámetro -y acepta automáticamente todos los términos
choco install vlc -y

# 2. Refrescar variables de entorno
# Esto permite que el sistema reconozca nuevas rutas sin reiniciar
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 3. Crear acceso directo en el escritorio público (para todos los usuarios)
$Shell = New-Object -ComObject WScript.Shell
$PublicDesktop = [System.IO.Path]::Combine($env:Public, "Desktop")
$Shortcut = $Shell.CreateShortcut("$PublicDesktop\VLC Media Player.lnk")

# Definir la ruta del ejecutable (ruta por defecto de VLC en 64 bits)
$VlcPath = "C:\Program Files\VideoLAN\VLC\vlc.exe"

if (Test-Path $VlcPath) {
    $Shortcut.TargetPath = $VlcPath
    $Shortcut.Description = "Reproductor multimedia VLC"
    $Shortcut.WorkingDirectory = "C:\Program Files\VideoLAN\VLC"
    $Shortcut.Save()
    Write-Host "Acceso directo creado con éxito."
} else {
    Write-Warning "No se encontró el ejecutable de VLC. Verifica la ruta de instalación."
}