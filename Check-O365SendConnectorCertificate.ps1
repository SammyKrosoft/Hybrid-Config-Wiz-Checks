$O365SendConnector = Get-SendConnector "Outbound to Office*"
$CertO365Connector = $O365Sendconnector.TlsCertificateName
#$CertO365Connector.CertificateSubject

$CertExchange = Get-ExchangeCertificate -Server E2016-01 | ? {$_.IsSelfSigned -eq $false -and $_.NotAfter -gt $(Get-Date) -and $_.Subject -like $CertO365Connector.CertificateSubject}
If ($CertExchange -eq $null){Write-Host "No certs found corresponding to the cert in the Outbound to O365 connector that is still valid :(" -ForegroundColor Red} Else {Write-Host "Found valid certificate registered for the Outbound to O365 Send connector" -ForegroundColor Green}
$CertExchange | fl Subject, NotAfter, Services

