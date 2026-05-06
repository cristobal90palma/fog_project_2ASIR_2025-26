# Instalar VLC usando Chocolatey
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

& "$env:ProgramData\chocolatey\bin\choco.exe" install vlc -y --no-progress
Start-Sleep -Seconds 10

# Crear acceso directo
$vlcPath = "C:\Program Files\VideoLAN\VLC\vlc.exe"
if (Test-Path $vlcPath) {
    $Shell = New-Object -ComObject WScript.Shell
    $Desktop = [System.IO.Path]::Combine($env:Public, "Desktop")
    $Shortcut = $Shell.CreateShortcut("$Desktop\VLC Media Player.lnk")
    $Shortcut.TargetPath = $vlcPath
    $Shortcut.Save()
    Write-Host "VLC instalado correctamente"
    exit 0
} else {
    Write-Host "ERROR: No se encontró VLC"
    exit 1
}