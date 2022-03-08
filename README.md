# Hybrid-Config-Wiz-Checks
This is to check Exchange Hybrid Config status.

> NOTE: the most common issues for HCW deployment failures is failure to open Firewall rules that are required for HCW to create and set objects Online. Other causes can be lack or misconfigured public DNS names pointing to your Edge or Exchange Mailbox servers in charge of communicating with O365, especially for inbound traffic (SMTP inbound or EWS inbound for Free/Busy info).

See the 2 links below for URLs/IPs to open inbound/outbound for Hybrid config and operation to work *(CTRL + Right Click to open on new tab)* : <br>
[Office 365 URLs and IP address ranges](https://docs.microsoft.com/en-us/microsoft-365/enterprise/urls-and-ip-address-ranges?view=o365-worldwide) <br>
[Hybrid deployment prerequisites](https://docs.microsoft.com/en-us/exchange/hybrid-deployment-prerequisites) <br>

> NOTE2: TLS 1.2 must be enabled on your OnPrem servers that will connect to O365 - check [this repository for a quick way to check if TLS1.2 is installed](https://github.com/SammyKrosoft/Check-or-Enable-TLS-1.2-with-PowerShell)

## What the Hybrid Configuration Wizard creates

My server I chose for Hybrid connection (bothfor Client Access and Mail flow) : ```E2016-01``` <br>
My primary SMTP domain : ```Contoso.ca``` <br>
My smarthost that I publish on Internet (public DNS resolution) : ```mail.contoso.ca``` <br>
My O365 tenant default name : ```contoso.onmicrosoft.com```

<Details>
<summary>New-* cmdlets ran by HCW </summary>

```powershell
New-HybridConfiguration
Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null -Domains 'Contoso.ca' -OnPremisesSmartHost 'mail.contoso.ca' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -SendingTransportServers 'E2016-01' -ReceivingTransportServers 'E2016-01' -EdgeTransportServers $null -Features FreeBusy,MoveMailbox,Mailtips,MessageTracking,OwaRedirection,OnlineArchive,SecureMail,Photos

# New-RemoteDomain
New-RemoteDomain -Name 'Hybrid Domain - contoso.mail.onmicrosoft.com' -DomainName 'contoso.mail.onmicrosoft.com'
New-RemoteDomain -Name 'Hybrid Domain - contoso.onmicrosoft.com' -DomainName 'contoso.onmicrosoft.com'

# New-AcceptedDomain
New-AcceptedDomain -DomainName 'contoso.mail.onmicrosoft.com' -Name 'contoso.mail.onmicrosoft.com'

# New-OrganizationRelationship
New-OrganizationRelationship -Name 'On-premises to O365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'contoso.mail.onmicrosoft.com'
New-OrganizationRelationship -Name 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'Contoso.ca'

# New-SendConnector
New-SendConnector -Name 'Outbound to Office 365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -AddressSpaces 'smtp:contoso.mail.onmicrosoft.com;1' -DNSRoutingEnabled: $true -ErrorPolicies Default -Fqdn 'mail.contoso.ca' -RequireTLS: $true -IgnoreSTARTTLS: $false -SourceTransportServers 'E2016-01' -SmartHosts $null -TLSAuthLevel DomainValidation -DomainSecureEnabled: $false -TLSDomain 'mail.protection.outlook.com' -CloudServicesMailEnabled: $true -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca'

# New-InboundConnector
New-InboundConnector -Name 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -CloudServicesMailEnabled: $true -ConnectorSource HybridWizard -ConnectorType OnPremises -RequireTLS: $true -SenderDomains '*' -SenderIPAddresses $null -RestrictDomainsToIPAddresses: $false -TLSSenderCertificateName 'mail.contoso.ca' -AssociatedAcceptedDomains $null

# New-OutboundConnector
New-OutboundConnector -Name 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -RecipientDomains 'Contoso.ca' -SmartHosts 'mail.contoso.ca' -ConnectorSource HybridWizard -ConnectorType OnPremises -TLSSettings DomainValidation -TLSDomain 'mail.contoso.ca' -CloudServicesMailEnabled: $true -RouteAllMessagesViaOnPremises: $false -UseMxRecord: $false -IsTransportRuleScoped: $false

# New-OnPremisesOrganization
New-OnPremisesOrganization -HybridDomains 'Contoso.ca' -InboundConnector 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OutboundConnector 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationRelationship 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationName CONTOSOMSG -Name 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationGuid 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5'

# New-IntraOrganizationConnector
New-IntraOrganizationConnector -Name 'HybridIOC - 177cd94d-be11-44e9-b09f-db69389f3a35' -DiscoveryEndpoint 'https://autodiscover-s.outlook.com/autodiscover/autodiscover.svc' -TargetAddressDomains 'contoso.mail.onmicrosoft.com' -Enabled: $true

# New-IntraOrganizationConnector
New-IntraOrganizationConnector -Name 'HybridIOC - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -DiscoveryEndpoint 'https://mail.contoso.ca/autodiscover/autodiscover.svc' -TargetAddressDomains 'Contoso.ca' -Enabled: $true

# New-AuthServer
New-AuthServer -Name 'ACS - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://accounts.accesscontrol.windows.net/e5923069-9fac-4809-b7c9-a0893265a0e0/metadata/json/1' -DomainName 'Contoso.ca','contoso.mail.onmicrosoft.com'
New-AuthServer -Name 'EvoSts - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://login.windows.net/contoso.onmicrosoft.com/federationmetadata/2007-06/federationmetadata.xml' -Type AzureAD

# Test-MigrationServerAvailability and New-MigrationEndpoint
# Before, HCW tests remove migration server availability
Test-MigrationServerAvailability -ExchangeRemoteMove: $true -RemoteServer 'mail.contoso.ca' -Credentials (Get-Credential -UserName contoso\samdrey)

New-MigrationEndpoint -Name 'Hybrid Migration Endpoint - EWS (Default Web Site)' -ExchangeRemoteMove: $true -RemoteServer 'mail.Contoso.ca' -Credentials (Get-Credential -UserName contoso\samdrey)
```
</details>

<details>
<summary>Set-* commands executed by the HCW</summary>
  
```powershell
Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null -Domains 'contoso.ca' -OnPremisesSmartHost 'mail.contoso.ca' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -SendingTransportServers 'E2016-01' -ReceivingTransportServers 'E2016-01' -EdgeTransportServers $null -Features FreeBusy,MoveMailbox,Mailtips,MessageTracking,OwaRedirection,OnlineArchive,SecureMail,Photos

Set-RemoteDomain -TargetDeliveryDomain: $true -Identity 'Hybrid Domain - contoso.mail.onmicrosoft.com'

Set-RemoteDomain -TrustedMailInboundEnabled: $true -Identity 'Hybrid Domain - contoso.onmicrosoft.com'

Set-EmailAddressPolicy -Identity 'Default Policy' -ForceUpgrade: $true -EnabledEmailAddressTemplates 'SMTP:@contoso.ca','smtp:%m@contoso.mail.onmicrosoft.com'

Set-OrganizationRelationship -MailboxMoveEnabled: $true -FreeBusyAccessEnabled: $true -FreeBusyAccessLevel LimitedDetails -ArchiveAccessEnabled: $true -MailTipsAccessEnabled: $true -MailTipsAccessLevel All -DeliveryReportEnabled: $true -PhotosEnabled: $true -TargetOwaURL 'http://outlook.com/owa/contoso.ca' -Identity 'On-premises to O365 - 177cd94d-be11-44e9-b09f-db69389f3a35'

Set-OrganizationRelationship -FreeBusyAccessEnabled: $true -FreeBusyAccessLevel LimitedDetails -TargetSharingEpr $null -MailTipsAccessEnabled: $true -MailTipsAccessLevel All -DeliveryReportEnabled: $true -PhotosEnabled: $true -TargetOwaURL 'https://mail.contoso.ca/owa' -Identity 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5'

Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null

Set-ReceiveConnector -AuthMechanism 'Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer' -Bindings '[::]:25','0.0.0.0:25' -Fqdn 'E2016-01.contoso.ca' -PermissionGroups 'AnonymousUsers, ExchangeServers, ExchangeLegacyServers' -RemoteIPRanges '::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff','0.0.0.0-255.255.255.255' -RequireTLS: $false -TLSDomainCapabilities 'mail.protection.outlook.com:AcceptCloudServicesMail' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -TransportRole FrontendTransport -Identity 'E2016-01\Default Frontend E2016-01'

Set-PartnerApplication -Identity 'Exchange Online' -Enabled: $true

Set-OnPremisesOrganization -Identity 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -Comment 'rZTLTsJQEIbnUYwPgIVyKQZZWCSaaFwUdV3bisjNtKDy8uo30+LCCAU1J6dn5szl/zsz7cd7R3xZSspKZCYL6clcphLKCO1ABrKSZywncigBcoZHgr2CtiBGvYbYumQJkUOJ2T3LtsIrQuvI0RaMLvYr9BjbPnh9Mk5Y53jdmyU2pHUuzXuN5Qk5ItbnfiYP+A1BSY1thp4gb8M9JW4OTmIROXKInnGjeLtiKB+fuFFRg1u7zdDnJZW+MP+m1A29Li3xpCEOpz6bUuX00NrIXlHtTTjKogcvzT3gbsp5gxaZFskYz925NMU1Ng7bNQbKrIFUY+UslU8ZorIKjOeLPX9fm5qtKrsNdl4Rz+5dtnLZjKMsLmGafXVyVvR1jpcvj5zKePucls3Lbgj5tHz36GNNLfpM3gw/Lfoc/XMfXeuhY5XTiWsVc/U3RvpWdxY35quYIL0yG0v7UhY7dHs9PwH2dXUd1jG7yrMO84q9RwNdWefzV4b5E68An8jeIrH/Sbxn1/X7XxY9L8/dlU8='
```

</details>

<details>
<summary>Set-* and New-* commands launched by HCW (include all of the above)</summary>

```powershell

Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null -Domains 'contoso.ca' -OnPremisesSmartHost 'mail.contoso.ca' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -SendingTransportServers 'E2016-01' -ReceivingTransportServers 'E2016-01' -EdgeTransportServers $null -Features FreeBusy,MoveMailbox,Mailtips,MessageTracking,OwaRedirection,OnlineArchive,SecureMail,Photos

New-RemoteDomain -Name 'Hybrid Domain - contoso.mail.onmicrosoft.com' -DomainName 'contoso.mail.onmicrosoft.com'

Set-RemoteDomain -TargetDeliveryDomain: $true -Identity 'Hybrid Domain - contoso.mail.onmicrosoft.com'

New-RemoteDomain -Name 'Hybrid Domain - contoso.onmicrosoft.com' -DomainName 'contoso.onmicrosoft.com'

Set-RemoteDomain -TrustedMailInboundEnabled: $true -Identity 'Hybrid Domain - contoso.onmicrosoft.com'

New-AcceptedDomain -DomainName 'contoso.mail.onmicrosoft.com' -Name 'contoso.mail.onmicrosoft.com'

Set-EmailAddressPolicy -Identity 'Default Policy' -ForceUpgrade: $true -EnabledEmailAddressTemplates 'SMTP:@contoso.ca','smtp:%m@contoso.mail.onmicrosoft.com'

New-OrganizationRelationship -Name 'On-premises to O365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'contoso.mail.onmicrosoft.com'

New-OrganizationRelationship -Name 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'contoso.ca'

Set-OrganizationRelationship -MailboxMoveEnabled: $true -FreeBusyAccessEnabled: $true -FreeBusyAccessLevel LimitedDetails -ArchiveAccessEnabled: $true -MailTipsAccessEnabled: $true -MailTipsAccessLevel All -DeliveryReportEnabled: $true -PhotosEnabled: $true -TargetOwaURL 'http://outlook.com/owa/contoso.ca' -Identity 'On-premises to O365 - 177cd94d-be11-44e9-b09f-db69389f3a35'

Set-OrganizationRelationship -FreeBusyAccessEnabled: $true -FreeBusyAccessLevel LimitedDetails -TargetSharingEpr $null -MailTipsAccessEnabled: $true -MailTipsAccessLevel All -DeliveryReportEnabled: $true -PhotosEnabled: $true -TargetOwaURL 'https://mail.contoso.ca/owa' -Identity 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5'

Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null

New-SendConnector -Name 'Outbound to Office 365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -AddressSpaces 'smtp:contoso.mail.onmicrosoft.com;1' -DNSRoutingEnabled: $true -ErrorPolicies Default -Fqdn 'mail.contoso.ca' -RequireTLS: $true -IgnoreSTARTTLS: $false -SourceTransportServers 'E2016-01' -SmartHosts $null -TLSAuthLevel DomainValidation -DomainSecureEnabled: $false -TLSDomain 'mail.protection.outlook.com' -CloudServicesMailEnabled: $true -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca'

Set-ReceiveConnector -AuthMechanism 'Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer' -Bindings '[::]:25','0.0.0.0:25' -Fqdn 'E2016-01.contoso.ca' -PermissionGroups 'AnonymousUsers, ExchangeServers, ExchangeLegacyServers' -RemoteIPRanges '::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff','0.0.0.0-255.255.255.255' -RequireTLS: $false -TLSDomainCapabilities 'mail.protection.outlook.com:AcceptCloudServicesMail' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -TransportRole FrontendTransport -Identity 'E2016-01\Default Frontend E2016-01'

New-InboundConnector -Name 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -CloudServicesMailEnabled: $true -ConnectorSource HybridWizard -ConnectorType OnPremises -RequireTLS: $true -SenderDomains '*' -SenderIPAddresses $null -RestrictDomainsToIPAddresses: $false -TLSSenderCertificateName 'mail.contoso.ca' -AssociatedAcceptedDomains $null

New-OutboundConnector -Name 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -RecipientDomains 'contoso.ca' -SmartHosts 'mail.contoso.ca' -ConnectorSource HybridWizard -ConnectorType OnPremises -TLSSettings DomainValidation -TLSDomain 'mail.contoso.ca' -CloudServicesMailEnabled: $true -RouteAllMessagesViaOnPremises: $false -UseMxRecord: $false -IsTransportRuleScoped: $false

New-OnPremisesOrganization -HybridDomains 'contoso.ca' -InboundConnector 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OutboundConnector 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationRelationship 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationName CONTOSOMSG -Name 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationGuid 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5'

New-IntraOrganizationConnector -Name 'HybridIOC - 177cd94d-be11-44e9-b09f-db69389f3a35' -DiscoveryEndpoint 'https://autodiscover-s.outlook.com/autodiscover/autodiscover.svc' -TargetAddressDomains 'contoso.mail.onmicrosoft.com' -Enabled: $true

New-IntraOrganizationConnector -Name 'HybridIOC - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -DiscoveryEndpoint 'https://mail.contoso.ca/autodiscover/autodiscover.svc' -TargetAddressDomains 'contoso.ca' -Enabled: $true

Set-PartnerApplication -Identity 'Exchange Online' -Enabled: $true

New-AuthServer -Name 'ACS - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://accounts.accesscontrol.windows.net/e5923069-9fac-4809-b7c9-a0893265a0e0/metadata/json/1' -DomainName 'contoso.ca','contoso.mail.onmicrosoft.com'

New-AuthServer -Name 'EvoSts - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://login.windows.net/contoso.onmicrosoft.com/federationmetadata/2007-06/federationmetadata.xml' -Type AzureAD

Test-MigrationServerAvailability -ExchangeRemoteMove: $true -RemoteServer 'mail.contoso.ca' -Credentials (Get-Credential -UserName contoso\samdrey)

New-MigrationEndpoint -Name 'Hybrid Migration Endpoint - EWS (Default Web Site)' -ExchangeRemoteMove: $true -RemoteServer 'mail.contoso.ca' -Credentials (Get-Credential -UserName contoso\samdrey)

Set-OnPremisesOrganization -Identity 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -Comment 'rZTLTsJQEIbnUYwPgIVyKQZZWCSaaFwUdV3bisjNtKDy8uo30+LCCAU1J6dn5szl/zsz7cd7R3xZSspKZCYL6clcphLKCO1ABrKSZywncigBcoZHgr2CtiBGvYbYumQJkUOJ2T3LtsIrQuvI0RaMLvYr9BjbPnh9Mk5Y53jdmyU2pHUuzXuN5Qk5ItbnfiYP+A1BSY1thp4gb8M9JW4OTmIROXKInnGjeLtiKB+fuFFRg1u7zdDnJZW+MP+m1A29Li3xpCEOpz6bUuX00NrIXlHtTTjKogcvzT3gbsp5gxaZFskYz925NMU1Ng7bNQbKrIFUY+UslU8ZorIKjOeLPX9fm5qtKrsNdl4Rz+5dtnLZjKMsLmGafXVyVvR1jpcvj5zKePucls3Lbgj5tHz36GNNLfpM3gw/Lfoc/XMfXeuhY5XTiWsVc/U3RvpWdxY35quYIL0yG0v7UhY7dHs9PwH2dXUd1jG7yrMO84q9RwNdWefzV4b5E68An8jeIrH/Sbxn1/X7XxY9L8/dlU8='

```

</details>

<details>
<summary>Set and New commands with sequence and which platform</summary>

| Sequence | Command Location | Cmd Line                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| -------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1        | OnPremises       | ``` Get-MailboxDatabase -IncludePreExchange2013:$true```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 2        | OnPremises       | ``` Get-FederatedOrganizationIdentifier -IncludeExtendedDomainInfo: $false ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 3        | OnPremises       | ``` Get-WebServicesVirtualDirectory -ADPropertiesOnly: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 4        | OnPremises       | ``` Get-ExchangeCertificate -Server 'E2016-01' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 5        | OnPremises       | ``` Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null -Domains 'contoso.ca' -OnPremisesSmartHost 'mail.contoso.ca' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -SendingTransportServers 'E2016-01' -ReceivingTransportServers 'E2016-01' -EdgeTransportServers $null -Features FreeBusy,MoveMailbox,Mailtips,MessageTracking,OwaRedirection,OnlineArchive,SecureMail,Photos ```                                                                                                                                                                   |
| 6        | OnPremises       | ``` Get-WebServicesVirtualDirectory -ADPropertiesOnly: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 7        | OnPremises       | ``` New-RemoteDomain -Name 'Hybrid Domain - contoso.mail.onmicrosoft.com' -DomainName 'contoso.mail.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| 8        | OnPremises       | ``` Set-RemoteDomain -TargetDeliveryDomain: $true -Identity 'Hybrid Domain - contoso.mail.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 9        | OnPremises       | ``` New-RemoteDomain -Name 'Hybrid Domain - contoso.onmicrosoft.com' -DomainName 'contoso.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 10       | OnPremises       | ``` Set-RemoteDomain -TrustedMailInboundEnabled: $true -Identity 'Hybrid Domain - contoso.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 11       | OnPremises       | ``` New-AcceptedDomain -DomainName 'contoso.mail.onmicrosoft.com' -Name 'contoso.mail.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 12       | OnPremises       | ``` Set-EmailAddressPolicy -Identity 'Default Policy' -ForceUpgrade: $true -EnabledEmailAddressTemplates 'SMTP:@contoso.ca','smtp:%m@contoso.mail.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 13       | OnPremises       | ``` Update-EmailAddressPolicy -Identity 'Default Policy' -UpdateSecondaryAddressesOnly: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 14       | OnPremises       | ``` New-OrganizationRelationship -Name 'On-premises to O365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'contoso.mail.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 15       | Tenant           | ``` New-OrganizationRelationship -Name 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'contoso.ca' ```                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 16       | OnPremises       | ``` Get-OwaVirtualDirectory -ADPropertiesOnly: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| 17       | OnPremises       | ``` Set-OrganizationRelationship -MailboxMoveEnabled: $true -FreeBusyAccessEnabled: $true -FreeBusyAccessLevel LimitedDetails -ArchiveAccessEnabled: $true -MailTipsAccessEnabled: $true -MailTipsAccessLevel All -DeliveryReportEnabled: $true -PhotosEnabled: $true -TargetOwaURL 'http://outlook.com/owa/contoso.ca' -Identity 'On-premises to O365 - 177cd94d-be11-44e9-b09f-db69389f3a35' ```                                                                                                                                                                                                                                                  |
| 18       | Tenant           | ``` Set-OrganizationRelationship -FreeBusyAccessEnabled: $true -FreeBusyAccessLevel LimitedDetails -TargetSharingEpr $null -MailTipsAccessEnabled: $true -MailTipsAccessLevel All -DeliveryReportEnabled: $true -PhotosEnabled: $true -TargetOwaURL 'https://mail.contoso.ca/owa' -Identity 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' ```                                                                                                                                                                                                                                                                                        |
| 19       | OnPremises       | ``` Add-AvailabilityAddressSpace -ForestName 'contoso.mail.onmicrosoft.com' -AccessMethod InternalProxy -UseServiceAccount: $true -ProxyUrl 'https://mail.contoso.ca/ews/Exchange.asmx' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 20       | OnPremises       | ``` Get-ExchangeCertificate -Server 'E2016-01' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 21       | OnPremises       | ``` Get-ReceiveConnector -Server 'E2016-01' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| 22       | OnPremises       | ``` Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 23       | OnPremises       | ``` New-SendConnector -Name 'Outbound to Office 365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -AddressSpaces 'smtp:contoso.mail.onmicrosoft.com;1' -DNSRoutingEnabled: $true -ErrorPolicies Default -Fqdn 'mail.contoso.ca' -RequireTLS: $true -IgnoreSTARTTLS: $false -SourceTransportServers 'E2016-01' -SmartHosts $null -TLSAuthLevel DomainValidation -DomainSecureEnabled: $false -TLSDomain 'mail.protection.outlook.com' -CloudServicesMailEnabled: $true -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' ```                                                               |
| 24       | OnPremises       | ``` Set-ReceiveConnector -AuthMechanism 'Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer' -Bindings '[::]:25','0.0.0.0:25' -Fqdn 'E2016-01.contoso.ca' -PermissionGroups 'AnonymousUsers, ExchangeServers, ExchangeLegacyServers' -RemoteIPRanges '::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff','0.0.0.0-255.255.255.255' -RequireTLS: $false -TLSDomainCapabilities 'mail.protection.outlook.com:AcceptCloudServicesMail' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -TransportRole FrontendTransport -Identity 'E2016-01\\Default Frontend E2016-01' ```    |
| 25       | Tenant           | ``` New-InboundConnector -Name 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -CloudServicesMailEnabled: $true -ConnectorSource HybridWizard -ConnectorType OnPremises -RequireTLS: $true -SenderDomains '*' -SenderIPAddresses $null -RestrictDomainsToIPAddresses: $false -TLSSenderCertificateName 'mail.contoso.ca' -AssociatedAcceptedDomains $null ```                                                                                                                                                                                                                                                                                   |
| 26       | Tenant           | ``` New-OutboundConnector -Name 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -RecipientDomains 'contoso.ca' -SmartHosts 'mail.contoso.ca' -ConnectorSource HybridWizard -ConnectorType OnPremises -TLSSettings DomainValidation -TLSDomain 'mail.contoso.ca' -CloudServicesMailEnabled: $true -RouteAllMessagesViaOnPremises: $false -UseMxRecord: $false -IsTransportRuleScoped: $false ```                                                                                                                                                                                                                                                  |
| 27       | Tenant           | ``` New-OnPremisesOrganization -HybridDomains 'contoso.ca' -InboundConnector 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OutboundConnector 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationRelationship 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationName contosoMSG -Name 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationGuid 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' ```                                                                                                                                                                                                                |
| 28       | OnPremises       | ``` Get-ReceiveConnector -Server 'E2016-01' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| 29       | Tenant           | ``` Get-IntraOrganizationConfiguration -OrganizationGuid 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 30       | OnPremises       | ``` New-IntraOrganizationConnector -Name 'HybridIOC - 177cd94d-be11-44e9-b09f-db69389f3a35' -DiscoveryEndpoint 'https://autodiscover-s.outlook.com/autodiscover/autodiscover.svc' -TargetAddressDomains 'contoso.mail.onmicrosoft.com' -Enabled: $true ```                                                                                                                                                                                                                                                                                                                                                                                          |
| 31       | Tenant           | ``` New-IntraOrganizationConnector -Name 'HybridIOC - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -DiscoveryEndpoint 'https://mail.contoso.ca/autodiscover/autodiscover.svc' -TargetAddressDomains 'contoso.ca' -Enabled: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                       |
| 32       | OnPremises       | ``` Get-ExchangeCertificate -Thumbprint CE5BE91C660D6E6213B95BEC6F84B045A431FC0C ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 33       | OnPremises       | ``` Get-ActiveSyncVirtualDirectory -ADPropertiesOnly: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| 34       | OnPremises       | ``` Get-PartnerApplication -Identity 'Exchange Online' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 35       | OnPremises       | ``` Set-PartnerApplication -Identity 'Exchange Online' -Enabled: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 36       | OnPremises       | ``` New-AuthServer -Name 'ACS - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://accounts.accesscontrol.windows.net/e5923069-9fac-4809-b7c9-a0893265a0e0/metadata/json/1' -DomainName 'contoso.ca','contoso.mail.onmicrosoft.com' ```                                                                                                                                                                                                                                                                                                                                                                                                |
| 37       | OnPremises       | ``` New-AuthServer -Name 'EvoSts - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://login.windows.net/contoso.onmicrosoft.com/federationmetadata/2007-06/federationmetadata.xml' -Type AzureAD ```                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 38       | Tenant           | ``` Get-IntraOrganizationConfiguration -OrganizationGuid 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 39       | Tenant           | ``` Test-MigrationServerAvailability -ExchangeRemoteMove: $true -RemoteServer 'mail.contoso.ca' -Credentials (Get-Credential -UserName contoso\\SAMDREY) ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 40       | Tenant           | ``` New-MigrationEndpoint -Name 'Hybrid Migration Endpoint - EWS (Default Web Site)' -ExchangeRemoteMove: $true -RemoteServer 'mail.contoso.ca' -Credentials (Get-Credential -UserName contoso\\samdrey) ```                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 41       | OnPremises       | ``` Get-WebServicesVirtualDirectory -ADPropertiesOnly: $true ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 42       | Tenant           | ``` Set-OnPremisesOrganization -Identity 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -Comment 'rZTLTsJQEIbnUYwPgIVyKQZZWCSaaFwUdV3bisjNtKDy8uo30+LCCAU1J6dn5szl/zsz7cd7R3xZSspKZCYL6clcphLKCO1ABrKSZywncigBcoZHgr2CtiBGvYbYumQJkUOJ2T3LtsIrQuvI0RaMLvYr9BjbPnh9Mk5Y53jdmyU2pHUuzXuN5Qk5ItbnfiYP+A1BSY1thp4gb8M9JW4OTmIROXKInnGjeLtiKB+fuFFRg1u7zdDnJZW+MP+m1A29Li3xpCEOpz6bUuX00NrIXlHtTTjKogcvzT3gbsp5gxaZFskYz925NMU1Ng7bNQbKrIFUY+UslU8ZorIKjOeLPX9fm5qtKrsNdl4Rz+5dtnLZjKMsLmGafXVyVvR1jpcvj5zKePucls3Lbgj5tHz36GNNLfpM3gw/Lfoc/XMfXeuhY5XTiWsVc/U3RvpWdxY35quYIL0yG0v7UhY7dHs9PwH2dXUd1jG7yrMO84q9RwNdWefzV4b5E68An8jeIrH/Sbxn1/X7XxY9L8/dlU8=' ``` |
|          |                  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

</details>

## Post HCW install tests to do

<details>
<summary>
Check EWS vdir configuration
</summary>

```powershell
Get-WebServicesVirtualDirectory -ADPropertiesOnly |ft ExternalAuthenticationMethods,InternalURL, Externalurl,MRSproxyEnabled,Server
```

> Expected: External URL matches published fqdn for migration endpoint, and potentially, ExternalURL should match InternalURL

</details>

<details>
  <summary>Test MRS health</summary>

```powershell
Test-MRSHealth | ft Identity, check, passed, IsValid, Message
```

> Expected: all pass. If Pass = False for an item, check Message to troubleshoot.

  </details>
  
  <details>
  <summary>Test EWS MRSProxy.svc URL</summary>

```html
https://mail.exampledomain/ews/mrsproxy.svc
```

> Expected: Authentication prompt pop-up. If not, EWS or MRSProxy is not configured.

  </details>
  
  <details>
  <summary>Test migration server availability</summary>

#### Test autodiscovery for migration endpoint

```powershell
$EmailAddress = "adminUser@contoso.ca"
$cred = Get-Credential

Test-MigrationServerAvailability -ExchangeRemoteMove -Autodiscover -EmailAddress $EmailAddress -Credentials $Cred
```

#### Test remote server FQDN

```powershell
$RemoteServerFQDN = "mail.contoso.ca"
Test-MigrationServerAvailability -ExchangeRemoteMove -RemoteServer $RemoteServerFQDN -Credentials(Get-Credential)
```

  </details>
  
  <details>
  <summary>Check HCW logs</summary>
    
#### HCW log location
  
By default, these logs are located here:
    
```
%UserProfile%\AppData\Roaming\Microsoft\Exchange Hybrid Configuration
```

> *What to check* : Check for errors, warnings, review PowerShell cmdlets ran buy the HCW (search for "Cmdlet=" string within the log)
  
#### What the HCW creates
  
HCW gathers many information from OnPrem and Online. Here's what it creates (sample from my Lab):
  
  ```powershell
New-MigrationEndpoint -Name 'Hybrid Migration Endpoint - EWS (Default Web Site)' -ExchangeRemoteMove: $true -RemoteServer 'mail.contoso.ca' -Credentials (Get-Credential -UserName CONTOSO\AdminUser01)
  ```
  
  > NOTE: For reference or "baseline", you'll find a log of a successful HCW deployment on this repository. The format is ```YYYYMMDD_HHMMSS.log``` under the above mentionned folder.
  
  </details>
  
  <details>
  <summary>Check IIS Logs</summary>

If you get something like this:

```output
WebExceptionStatus=ProtocolError;ResponseStatusCode=400;WebException=System.Net.WebException: The remote server returned an error: (400) Bad Request.    at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)    at Microsoft.Exchange.HttpProxy.ProxyRequestHandler.<>c__DisplayClass2c.<OnResponseReady>b__2b()
```

Check that ExternalURL matches the published Remote Migration Endpoint FQDN and reachable from outside

  </details>
