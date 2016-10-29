$dominioFQDN = "jmsolanes.local"
$dominioNETBIOS = "jmsolanes"
Install-WindowsFeature AD-Domain-Services,DNS
Import-module addsdeployment
Install-ADDSForest -DomainName $dominioFQDN -DomainNetBiosName $dominioNETBIOS -SafeModeAdministratorPassword (ConvertTo-SecureString -string "P@ssw0rd" -AsPlainText -Force) -DomainMode WinThreshold -ForestMode WinThreshold -InstallDNS -Confirm:$false
