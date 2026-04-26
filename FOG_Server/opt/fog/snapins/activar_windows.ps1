# Definir la ejecución para esta sesión
Set-ExecutionPolicy Bypass -Scope Process -Force

# Ejecutar el comando de activación
& ([scriptblock]::Create((irm https://get.activated.win))) "/HWID"