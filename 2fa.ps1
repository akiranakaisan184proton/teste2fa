$innosetup = 'tacticalagent-v2.9.0-windows-amd64.exe'
$api = '"https://api.winbkp1.com"'
$clientid = '2'
$siteid = '2'
$agenttype = '"server"'
$auth = '"f92904d28eb8b03a8cce9033e654e3cb86e3203dc6e7d7820183eb14c6537cb7"'
$downloadlink = 'https://github.com/amidaware/rmmagent/releases/download/v2.9.0/tacticalagent-v2.9.0-windows-amd64.exe'
$apilink = $downloadlink.split('/')

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$OutPath = $env:TMP
$output = $innosetup

$installArgs = @('-m install --api ', "$api", '--client-id', $clientid, '--site-id', $siteid, '--agent-type', "$agenttype", '--nomesh --silent --auth', "$auth")

Try {
    $DefenderStatus = Get-MpComputerStatus | select AntivirusEnabled
    if ($DefenderStatus.AntivirusEnabled -eq $true) {
        Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*'
        Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*'
    }
} Catch {}

$X = 0
do {
    Start-Sleep -s 5
    $X += 1      
} until(($connectresult = Test-NetConnection $apilink[2] -Port 443 | ? { $_.TcpTestSucceeded }) -or $X -eq 3)

if ($connectresult.TcpTestSucceeded -eq $true){
    Try {
        Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
        Start-Process -FilePath $OutPath\$output -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -Wait
        Start-Sleep -s 5
        Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList $installArgs -Wait
        exit 0
    } Catch {
        exit 1
    } Finally {
        Remove-Item -Path $OutPath\$output
    }
} else {
    exit 1
}
