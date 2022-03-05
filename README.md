# Hybrid-Config-Wiz-Checks
This is to check Exchange Hybrid Config status

## Test Hybrid Configuration Wizard

```powershell
```

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
