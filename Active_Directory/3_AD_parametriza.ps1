$dominioFQDN = "jmsolanes.local"
$dominioLDAP = ",DC=jmsolanes,DC=local"
$ReenviaDNS1 = "8.8.8.8" 
$ReenviaDNS2 = "8.8.4.4" 
$RedInversa = "192.168.1.0/24"
Enable-ADOptionalFeature -Identity ("cn=Recycle Bin Feature,cn=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration" + $dominioLDAP) -Scope ForestOrConfigurationSet -target $dominioFQDN -Confirm:$false
Set-DNSServerForwarder -IPAddress $ReenviaDNS1,$ReenviaDNS2 
Set-DnsServerDiagnostics -EventLogLevel 1 
Add-DNSServerPrimaryZone -NetworkId $RedInversa -ReplicationScope "Forest" -DynamicUpdate Secure -Confirm:$false 
Register-DNSClient
