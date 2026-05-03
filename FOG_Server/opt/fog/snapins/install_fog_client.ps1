# Definir variables
$fogServer = "10.2.7.5"
$tempPath = "C:\fogtemp"
$msiPath = "$tempPath\fog.msi"

# Crear directorio temporal si no existe
if (!(Test-Path $tempPath)) {
    New-Item -Path $tempPath -ItemType Directory -Force
}

# Descargar el instalador
Invoke-WebRequest -Uri "http://$fogServer/fog/client/download.php?newclient" -OutFile $msiPath

# Instalación silenciosa
# WEBADDRESS: Tu servidor FOG
# /qn: Modo totalmente silencioso
Start-Process msiexec.exe -ArgumentList "/i $msiPath /quiet /qn WEBADDRESS=`"$fogServer`"" -Wait

# Configurar y asegurar el arranque del servicio
Set-Service 'FOGService' -StartupType Automatic
Start-Service 'FOGService'

# Limpieza
Remove-Item -Path $tempPath -Recurse -Force