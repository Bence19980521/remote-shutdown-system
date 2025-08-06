@echo off
echo Frissited service deploy...

echo 1. Service leallitas...
sc stop RemoteShutdownService

echo 2. Build...
cd WindowsService
dotnet build -c Release
cd ..

echo 3. Service inditasa...
sc start RemoteShutdownService

echo Kesz! Ellenorizd a logokat:
echo Get-EventLog -LogName Application -Source "RemoteShutdownService" -Newest 3

pause
