using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.

Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$params = $Request.Body | ConvertFrom-Json

if (-not $params) {
    $params = $Request.Body
}

if ($params) {
    $status = [HttpStatusCode]::OK
    $action = $params.action
    $region = $params.region
    $dnslabel = $params.dnslabel
    $kvname = $ENV:AZURE_KEYVAULT_NAME
    $resourceGroupName = $ENV:AZURE_RG_NAME
    $containerName = "shadowsocks"


    if ($action -icontains "start")
    {
     try 
        {
        $vpnpass = (Get-AzKeyVaultSecret -VaultName $kvname -Name VPNSecret).SecretValueText
        $envVars = @{
            PASSWORD = $vpnpass
        }
        $containerParams = @{
            Name = $containerName
            ResourceGroupName = $resourceGroupName
            EnvironmentVariable = $envVars
            Location = $region
            Image = "shadowsocks/shadowsocks-libev"
            IpAddressType = "public"
            DNSNameLabel = $dnslabel
            Port = 8388
        }
    

        $containerGroup = New-AzContainerGroup @containerParams

        $body = Write-Output $containerGroup.IpAddress
        }
        
    catch 
        {
        Write-Error -Message $_.Exception
        $body = throw $_.Exception
        }
    }
    elseif ($action -icontains "stop")
        {
        Remove-AzContainerGroup -Name $containerName -ResourceGroupName $resourceGroupName
        $body = "$($containerName) deleted"
        }

}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a valid request in the body."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})