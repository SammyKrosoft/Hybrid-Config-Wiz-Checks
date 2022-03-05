# Hybrid-Config-Wiz-Checks
This is to check Exchange Hybrid Config status

## What the Hybrid Configuration Wizard creates

```powershell
New-HybridConfiguration
Set-HybridConfiguration -ClientAccessServers $null -ExternalIPAddresses $null -Domains 'CanadaDrey.ca' -OnPremisesSmartHost 'mail.contoso.ca' -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca' -SendingTransportServers 'E2016-01' -ReceivingTransportServers 'E2016-01' -EdgeTransportServers $null -Features FreeBusy,MoveMailbox,Mailtips,MessageTracking,OwaRedirection,OnlineArchive,SecureMail,Photos

# New-RemoteDomain
New-RemoteDomain -Name 'Hybrid Domain - canadadrey.mail.onmicrosoft.com' -DomainName 'canadadrey.mail.onmicrosoft.com'
New-RemoteDomain -Name 'Hybrid Domain - canadadrey.onmicrosoft.com' -DomainName 'canadadrey.onmicrosoft.com'

# New-AcceptedDomain
New-AcceptedDomain -DomainName 'canadadrey.mail.onmicrosoft.com' -Name 'canadadrey.mail.onmicrosoft.com'

# New-OrganizationRelationship
New-OrganizationRelationship -Name 'On-premises to O365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'canadadrey.mail.onmicrosoft.com'
New-OrganizationRelationship -Name 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -TargetApplicationUri $null -TargetAutodiscoverEpr $null -Enabled: $true -DomainNames 'CanadaDrey.ca'

# New-SendConnector
New-SendConnector -Name 'Outbound to Office 365 - 177cd94d-be11-44e9-b09f-db69389f3a35' -AddressSpaces 'smtp:canadadrey.mail.onmicrosoft.com;1' -DNSRoutingEnabled: $true -ErrorPolicies Default -Fqdn 'mail.contoso.ca' -RequireTLS: $true -IgnoreSTARTTLS: $false -SourceTransportServers 'E2016-01' -SmartHosts $null -TLSAuthLevel DomainValidation -DomainSecureEnabled: $false -TLSDomain 'mail.protection.outlook.com' -CloudServicesMailEnabled: $true -TLSCertificateName '<I>CN=GeoTrust TLS DV RSA Mixed SHA256 2020 CA-1, O=DigiCert Inc, C=US<S>CN=mail.contoso.ca'

# New-InboundConnector
New-InboundConnector -Name 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -CloudServicesMailEnabled: $true -ConnectorSource HybridWizard -ConnectorType OnPremises -RequireTLS: $true -SenderDomains '*' -SenderIPAddresses $null -RestrictDomainsToIPAddresses: $false -TLSSenderCertificateName 'mail.contoso.ca' -AssociatedAcceptedDomains $null

New-OutboundConnector -Name 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -RecipientDomains 'CanadaDrey.ca' -SmartHosts 'mail.contoso.ca' -ConnectorSource HybridWizard -ConnectorType OnPremises -TLSSettings DomainValidation -TLSDomain 'mail.contoso.ca' -CloudServicesMailEnabled: $true -RouteAllMessagesViaOnPremises: $false -UseMxRecord: $false -IsTransportRuleScoped: $false

New-OnPremisesOrganization -HybridDomains 'CanadaDrey.ca' -InboundConnector 'Inbound from a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OutboundConnector 'Outbound to a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationRelationship 'O365 to On-premises - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationName CANADADREYMSG -Name 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -OrganizationGuid 'a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5'

New-IntraOrganizationConnector -Name 'HybridIOC - 177cd94d-be11-44e9-b09f-db69389f3a35' -DiscoveryEndpoint 'https://autodiscover-s.outlook.com/autodiscover/autodiscover.svc' -TargetAddressDomains 'canadadrey.mail.onmicrosoft.com' -Enabled: $true

New-IntraOrganizationConnector -Name 'HybridIOC - a3e87a2d-b84e-43cb-bf18-59aac4c4f1e5' -DiscoveryEndpoint 'https://mail.contoso.ca/autodiscover/autodiscover.svc' -TargetAddressDomains 'CanadaDrey.ca' -Enabled: $true

New-AuthServer -Name 'ACS - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://accounts.accesscontrol.windows.net/e5923069-9fac-4809-b7c9-a0893265a0e0/metadata/json/1' -DomainName 'CanadaDrey.ca','canadadrey.mail.onmicrosoft.com'

New-AuthServer -Name 'EvoSts - 177cd94d-be11-44e9-b09f-db69389f3a35' -AuthMetadataUrl 'https://login.windows.net/canadadrey.onmicrosoft.com/federationmetadata/2007-06/federationmetadata.xml' -Type AzureAD

New-MigrationEndpoint -Name 'Hybrid Migration Endpoint - EWS (Default Web Site)' -ExchangeRemoteMove: $true -RemoteServer 'mail.canadadrey.ca' -Credentials (Get-Credential -UserName CANADADREY\samdrey)
```



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
