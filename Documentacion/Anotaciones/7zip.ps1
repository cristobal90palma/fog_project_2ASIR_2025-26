choco install 7zip -y
$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut("$([System.IO.Path]::Combine($env:Public, 'Desktop'))\7-Zip.lnk")
$Shortcut.TargetPath = "C:\Program Files\7-Zip\7zFM.exe"
$Shortcut.Save()