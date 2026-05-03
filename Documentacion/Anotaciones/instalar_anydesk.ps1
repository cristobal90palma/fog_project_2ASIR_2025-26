# 1. Instalar AnyDesk forzando la instalación del servicio
# Usamos --install-arguments para asegurar que se registre como software instalado
choco install anydesk.install -y

# 2. Refrescar variables de entorno
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 3. Intentar localizar el ejecutable (AnyDesk varía entre x86 y x64)
$Paths = @(
    "C:\Program Files (x86)\AnyDesk\AnyDesk.exe",
    "C:\Program Files\AnyDesk\AnyDesk.exe",
    "$env:ProgramData\AnyDesk\AnyDesk.exe"
)

$AppPath = ""
foreach ($Path in $Paths) {
    if (Test-Path $Path) {
        $AppPath = $Path
        break
    }
}

# 4. Crear acceso directo si se encontró el archivo
if ($AppPath -ne "") {
    $Shell = New-Object -ComObject WScript.Shell
    $PublicDesktop = [System.IO.Path]::Combine($env:Public, "Desktop")
    $Shortcut = $Shell.CreateShortcut("$PublicDesktop\AnyDesk.lnk")
    $Shortcut.TargetPath = $AppPath
    $Shortcut.WorkingDirectory = (Split-Path $AppPath)
    $Shortcut.Save()
    Write-Host "AnyDesk encontrado en $AppPath y acceso directo creado."
} else {
    Write-Error "No se pudo encontrar el ejecutable de AnyDesk tras la instalación."
}