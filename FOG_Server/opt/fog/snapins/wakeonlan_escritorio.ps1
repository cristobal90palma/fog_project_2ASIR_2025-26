# 1. Definir variables
$fogServer = "10.2.7.5"
$fileName = "WakeOnLanMonitor.exe"
$installDir = "C:\Program Files\WOL"
$destPath = "$installDir\$fileName"

# 2. Crear el directorio en Program Files (más seguro que el escritorio)
if (!(Test-Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory -Force
}

# 3. Descargar el ejecutable desde el servidor FOG
$downloadUrl = "http://$fogServer/fog/client/download.php?snapin&name=$fileName"
Invoke-WebRequest -Uri $downloadUrl -OutFile $destPath

# 4. Desbloquear el archivo (Esto evita que Windows impida su ejecución)
Unblock-File -Path $destPath

# 5. Crear SOLO el acceso directo en el escritorio público
$Shell = New-Object -ComObject WScript.Shell
$PublicDesktop = [System.IO.Path]::Combine($env:Public, "Desktop")
$Shortcut = $Shell.CreateShortcut("$PublicDesktop\Wake On Lan Monitor.lnk")
$Shortcut.TargetPath = $destPath
$Shortcut.WorkingDirectory = $installDir
$Shortcut.Save()

# 6. Notificar éxito
Write-Host "WOL instalado en $installDir y acceso directo creado."