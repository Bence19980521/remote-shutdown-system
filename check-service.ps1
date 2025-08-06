# Windows Service ellenőrzési útmutató

## 1. Service Manager (Grafikus felület)
# Windows gomb + R → services.msc → Enter
# Keresd meg: "Remote Shutdown Service" vagy "RemoteShutdownService"
# Itt látod az állapotot: Running / Stopped
# Itt tudod elindítani/leállítani

## 2. PowerShell parancsok (bármilyen PowerShell-ben)
Get-Service -Name "RemoteShutdownService"

## 3. Command Prompt parancsok
sc.exe query RemoteShutdownService

## 4. Task Manager
# Ctrl + Shift + Esc → Services tab → RemoteShutdownService keresése

## 5. Event Log ellenőrzése (hibák esetén)
Get-EventLog -LogName Application -Source RemoteShutdownService -Newest 10

## 6. Service restart parancsok (csak rendszergazdaként!)
# Leállítás:
# sc.exe stop RemoteShutdownService

# Indítás:
# sc.exe start RemoteShutdownService

# Újraindítás:
# Restart-Service -Name "RemoteShutdownService"
