$nombreservidor = "srvDC1"
$IP = "192.168.1.203"
$Mascara = 24
$Puerta = "192.168.1.201"
$DNS = $IP

rename-computer -computername $env:computername -newname $nombreservidor
$tarjeta = Get-NetAdapter | ? {$_.Status -eq "up"}
if (($tarjeta | Get-NetIpConfiguration).IPv4Address.IPAddress) { $tarjeta | Remove-NetIpAddress -AddressFamily IPv4 -Confirm:$false }
if (($tarjeta | Get-NetIpConfiguration).IPv4DefaultGateway) { $tarjeta | Remove-NetRoute -AddressFamily IPv4 -Confirm:$false }
$tarjeta | New-NetIpAddress -AddressFamily IPv4 -IPAddress $IP -PrefixLength $Mascara -DefaultGateway $Puerta
$tarjeta | set-DNSClientServerAddress -ServerAddress $DNS
shutdown /r /t 0 /f
