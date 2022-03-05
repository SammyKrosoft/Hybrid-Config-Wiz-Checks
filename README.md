# Hybrid-Config-Wiz-Checks
This is to check Exchange Hybrid Config status

## Test Hybrid Configuration Wizard

```powershell
```

<details>
<summary>
### Check EWS vdir configuration
</summary>

```powershell
Get-WebServicesVirtualDirectory -ADPropertiesOnly |ft ExternalAuthenticationMethods,InternalURL, Externalurl,MRSproxyEnabled,Server
```

Expected: External URL matches published fqdn for migration endpoint, and potentially, ExternalURL should match InternalURL

</details>

### Test MRS health

```powershell
Test-MRSHealth | ft Identity, check, passed, IsValid, Message
```

Expected: all pass. If Pass = False for an item, check Message to troubleshoot.

### Test EWS MRSProxy.svc URL

```html
https://mail.exampledomain/ews/mrsproxy.svc
```

Expected: Authentication prompt pop-up. If not, EWS or MRSProxy is not configured.

### Test migration server availability

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

### Check IIS Logs

If you get something like this:

```output
WebExceptionStatus=ProtocolError;ResponseStatusCode=400;WebException=System.Net.WebException: The remote server returned an error: (400) Bad Request.    at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)    at Microsoft.Exchange.HttpProxy.ProxyRequestHandler.<>c__DisplayClass2c.<OnResponseReady>b__2b()
```

Check that ExternalURL matches the published Remote Migration Endpoint FQDN
