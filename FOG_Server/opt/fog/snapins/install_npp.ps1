# 1. Configurar la sesión para Chocolatey
$chocolateyBin = "$env:ProgramData\chocolatey\bin"
$chocolateyLib = "$env:ProgramData\chocolatey\lib"

# Asegurar que Chocolatey esté en PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Cargar los módulos de Chocolatey
Import-Module "$env:ProgramData\chocolatey\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue

# 2. Instalar Notepad++ usando chocolatey directamente
try {
    # Método 1: Usar choco.exe directamente
    & "$env:ProgramData\chocolatey\bin\choco.exe" install notepadplusplus -y --no-progress
    
    # Esperar a que termine la instalación
    Start-Sleep -Seconds 10
    
    # Verificar instalación
    $nppExe = "C:\Program Files\Notepad++\notepad++.exe"
    
    if (Test-Path $nppExe) {
        # Crear acceso directo en escritorio público
        $Shell = New-Object -ComObject WScript.Shell
        $DesktopPath = [System.IO.Path]::Combine($env:Public, "Desktop")
        $Shortcut = $Shell.CreateShortcut("$DesktopPath\Notepad++.lnk")
        $Shortcut.TargetPath = $nppExe
        $Shortcut.WorkingDirectory = "C:\Program Files\Notepad++"
        $Shortcut.Save()
        
        Write-Host "SUCCESS: Notepad++ instalado correctamente"
        exit 0
    } else {
        Write-Host "ERROR: No se encontró el ejecutable después de la instalación"
        exit 1
    }
}
catch {
    Write-Host "ERROR: Falló la instalación - $_"
    exit 1
}
