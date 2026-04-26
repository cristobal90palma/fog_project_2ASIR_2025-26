# 1. Instalar Notepad++ usando Chocolatey de forma silenciosa
choco install notepadplusplus -y

# 2. Refrescar variables por si acaso
$env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"

# 3. Crear acceso directo en el escritorio público (para todos los usuarios)
$Shell = New-Object -ComObject WScript.Shell
$DesktopPath = [System.IO.Path]::Combine($env:Public, "Desktop")
$Shortcut = $Shell.CreateShortcut("$DesktopPath\Notepad++.lnk")
$Shortcut.TargetPath = "C:\Program Files\Notepad++\notepad++.exe"
$Shortcut.Save()