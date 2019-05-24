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
    $vpnpass = Get-Variable -Name "AZURE_KEYVAULT_SECRET"

    $resourceGroupName = "shadowsocks"


    if ($action -icontains "start")
    {
     try 
        {
        $resourceGroupObject = Get-AzResourceGroup -Name $resourceGroupName -ea 0
            if(!($resourceGroupObject)){
                $resourceGroupObject = New-AzResourceGroup -Name $resourceGroupName -Location $region
            }
        $containerParams = @{
            Name = "shadowsocks"
            ResourceGroupName = $resourceGroupObject.ResourceGroupName
            Command = "/usr/local/bin/ssserver -k $($vpnpass) -m aes-256-cfb"
            Location = $resourceGroupObject.Location
            Image = "oddrationale/docker-shadowsocks"
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
        Remove-AzResourceGroup -Name $resourceGroupName -Force -Confirm:$false
        $body = "$($resourceGroupName) deleted"
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