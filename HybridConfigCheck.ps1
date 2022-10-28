# HCW Sets HybridConfig object
# =================================================================
# OnPrem : HCW sets Hybridconfig
Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null -Domains 'contoso.ca' -OnPremisesSmartHost 'mail.contoso.ca' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -SendingTransportServers 'E2016-01' -ReceivingTransportServers 'E2016-01' -EdgeTransportServers $null -Features FreeBusy,MoveMailbox,Mailtips,MessageTracking,OwaRedirection,OnlineArchive,SecureMail,Photos
# Check HybridConfig from OnPrem EMS
$HybridConfig = Get-HybridConfiguration | Select ClientAccessServers, ExternalIPAddresses, Domains, OnPremisesSmartHost, TLSCertificateName, SendingTransportServers, ReceivingTransportServers, EdgeTransportServers, Features
$HybridConfig = Get-HybridConfiguration
$HybridConfig | fl
# Additionnally, check the certificate expiry date, also from OnPrem EMS:
$HybridConfig.TlsCertificateName | fl *
Get-ChildItem -path cert:\LocalMachine\My | ? {$_.Subject -eq $($HybridConfig.TlsCertificateName.CertificateSubject)} | fl Subject, Issuer, NotBefore, NotAfter

# HCW Creates RemoteDomains mail.onmicrosoft.com and onmicrosoft.com
# =================================================================
# OnPrem: HCW create new RemoteDomain <tenant name>.mail.onmicrosoft.com, and sets that domain properties
New-RemoteDomain -Name 'Hybrid Domain - contoso.mail.onmicrosoft.com' -DomainName 'contoso.mail.onmicrosoft.com'
Set-RemoteDomain -TargetDeliveryDomain: $true -Identity 'Hybrid Domain - contoso.mail.onmicrosoft.com'
# Check that RemoteDomain from OnPrem EMS
$RemoteDomainMailOnMicrosoft = Get-RemoteDomain | Select Name, DomainName, TargetDeliveryDomain, Identity | ? {$_.Name -like "Hybrid Domain*" -and $_.Name -like "*mail.onmicrosoft.com"}
$RemoteDomainMailOnMicrosoft | fl

# OnPrem: HCW creates new RemoteDomain <tenant name>.onmicrosoft.com and sets that domain properties
New-RemoteDomain -Name 'Hybrid Domain - contoso.onmicrosoft.com' -DomainName 'contoso.onmicrosoft.com'
Set-RemoteDomain -TrustedMailInboundEnabled: $true -Identity 'Hybrid Domain - contoso.onmicrosoft.com'
# Check that RemoteDomain from OnPrem EMS
$RemoteDomainOnMicrosoft = Get-RemoteDomain | Select NAme, DomainName, TrustedMailInboundEnabled, Identity | ? {$_.Name -like "Hybrid Domain*" -and $_.Name -like "*.onmicrosoft.com" -and $_.Name -notlike "*mail.onmicrosoft.com"}
$RemoteDomainOnMicrosoft | fl

# HCW Creates AcceptedDomain mail.onmicrosoft.com
# =================================================================
# OnPrem : HCW creates new AcceptedDomain <tenant name>.mail.onmicrosoft.com
New-AcceptedDomain -DomainName 'contoso.mail.onmicrosoft.com' -Name 'contoso.mail.onmicrosoft.com'
# Check that AcceptedDomain from OnPrem EMS
$AcceptedDomain = Get-AcceptedDomain | ? {$_.Name -like "*mail.onmicrosoft.com" } | Select DomainName, Name
$AcceptedDomain | fl


# OnPrem: HCW sets and updates default Email address policy
Set-EmailAddressPolicy -Identity 'Default Policy' -ForceUpgrade:$true -EnabledEmailAddressTemplates 'SMTP:@contoso.ca','smtp:%m@contoso.mail.onmicrosoft.com'
Update-EmailAddressPolicy -Identity 'Default Policy' -UpdateSecondaryAddressesOnly:$true
# Check the EmailAddressPolicy settings from OnPrem EMS
$EmailAddressPolicy = Get-EmailAddressPolicy "Default Policy" | Select Identity, EnabledEmailAddressTemplates
$EmailAddressPolicy | fl
