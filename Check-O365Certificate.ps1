<# Objective: 

Check certificate info on Hybrid components.

Requires Exchange Management Tools (Exchange Management Shell) for some cmdlets, 
and Exchange Online Management tools for others.

#>

##################################################### Cert on Send Connector To O365 #####################################################
cls
Write-Host "Checking Outbound to O365 Send Connector" -BackgroundColor Yellow -ForegroundColor Blue

$O365SendConnector = Get-SendConnector "Outbound to Office*"
$CertO365Connector = $O365Sendconnector.TlsCertificateName
#$CertO365Connector.CertificateSubject

$CertExchange = Get-ExchangeCertificate -Server E2016-01 | ? {$_.IsSelfSigned -eq $false -and $_.NotAfter -gt $(Get-Date) -and $_.Subject -like $CertO365Connector.CertificateSubject}
If ($CertExchange -eq $null){Write-Host "No certs found corresponding to the cert in the Outbound to O365 connector that is still valid :(" -ForegroundColor Red} Else {Write-Host "Found valid certificate registered for the Outbound to O365 Send connector" -ForegroundColor Green}
$CertExchange | fl Subject, NotAfter, Services


################################################### Cert on Receive Connector from O365 ###################################################

Write-Host "Checking Receive Connector from tenant" -BackgroundColor Yellow -ForegroundColor Blue


Set-ReceiveConnector -AuthMechanism 'Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer' `
    -Bindings '[::]:25','0.0.0.0:25' `
    -Fqdn 'E2016-01.CanadaDrey.ca' `
    -PermissionGroups 'AnonymousUsers, ExchangeServers, ExchangeLegacyServers' `
    -RemoteIPRanges '::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff','0.0.0.0-255.255.255.255' `
    -RequireTLS: $false `
    -TLSDomainCapabilities 'mail.protection.outlook.com:AcceptCloudServicesMail' `
    -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.canadasam.ca' `
    -TransportRole FrontendTransport `
    -Identity 'E2016-01\Default Frontend E2016-01'


$Server = "E2016-01"
$O365HybridReceiveConnector = Get-ReceiveConnector -Server $Server | ? {$_.Name -like "*default frontend*"}
$CertO365ReceiveConnector = $O365HybridReceiveConnector.TlsCertificateName

$CertO365ReceiveConnector 

$CertExchange2 = Get-ExchangeCertificate -Server E2016-01 | ? {$_.IsSelfSigned -eq $false -and $_.NotAfter -gt $(Get-Date) -and $_.Subject -like $CertO365ReceiveConnector.CertificateSubject}
If ($CertExchange2 -eq $null){Write-Host "No certs found corresponding to the cert in the Outbound to O365 Receive Connector that is still valid :(" -ForegroundColor Red} Else {Write-Host "Found valid certificate registered for the Outbound to O365 Receive Connector" -ForegroundColor Green}
$CertExchange2 | fl Subject, NotAfter, Services

