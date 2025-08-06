@echo off
title Remote Shutdown Service Update

REM Ellenorizzuk az admin jogokat
net session >nul 2>&1
if NOT %errorLevel% == 0 (
    echo Ez a script rendszergazdai jogokat igenyel!
    echo.
    echo Kattints jobb egerrel a fajlra es valaszd:
    echo "Futtatas rendszergazdakent"
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo  Remote Shutdown Service Force Update
echo ==========================================
echo.

echo 1. Service leallitasa...
sc stop RemoteShutdownService
timeout /t 3 /nobreak >nul

echo 2. Service torlese...
sc delete RemoteShutdownService
timeout /t 2 /nobreak >nul

echo 3. Uj verzio buildese...
cd WindowsService
dotnet build -c Release
if ERRORLEVEL 1 (
    echo Build hiba!
    pause
    exit /b 1
)

echo 4. Service ujratelepitese...
cd ..
set SERVICE_PATH=%CD%\WindowsService\bin\Release\net8.0-windows\RemoteShutdownService.exe

sc create RemoteShutdownService binPath= "%SERVICE_PATH%" start= auto
if ERRORLEVEL 1 (
    echo Service letrehozasi hiba!
    pause
    exit /b 1
)

echo 5. Service inditasa...
sc start RemoteShutdownService
if ERRORLEVEL 1 (
    echo Service inditasi hiba!
    pause
    exit /b 1
)

echo.
echo ======================================
echo  Service sikeresen frissitve!
echo ======================================
echo.

echo Service allapot:
sc query RemoteShutdownService

echo.
echo Nyomj egy billentyut a kilepes...
pause >nul
