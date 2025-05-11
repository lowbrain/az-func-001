using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

If($env:AZURE_FUNCTIONS_ENVIRONMENT -eq "Development"){
    Connect-MgGraph -EnvironmentVariable -NoWelcome
}Else{
    Connect-MgGraph -Identity
}

Import-Module Microsoft.Graph.Users
$nowdate = (Get-Date).ToUniversalTime()
$userlist = Get-MgUser
$users= $userlist | Select-Object -Property @{Name="TimeGenerated";Expression={$nowdate}}, id, displayName, userPrincipalName, accountEnabled, proxyAddresses
$users | ConvertTo-Json

$body = $users | ConvertTo-Json

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
