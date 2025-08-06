# Egyszerű manuális telepítési útmutató
# Copy-paste ezeket a parancsokat a rendszergazdai PowerShell-be:

# 1. Navigálj a projekt mappába
cd "C:\Users\User\Desktop\geplallito"

# 2. Build-eld a service-t
cd WindowsService
dotnet publish -c Release -r win-x64 --self-contained

# 3. Telepítsd a Windows Service-t
$servicePath = "C:\Users\User\Desktop\geplallito\WindowsService\bin\Release\net8.0-windows\win-x64\publish\RemoteShutdownService.exe"
sc.exe create RemoteShutdownService binPath= $servicePath start= auto DisplayName= "Remote Shutdown Service"

# 4. Indítsd el a service-t
sc.exe start RemoteShutdownService

# 5. Ellenőrizd az állapotot
sc.exe query RemoteShutdownService
