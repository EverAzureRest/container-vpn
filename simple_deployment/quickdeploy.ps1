param (
[cmdletbinding()]
$password,
$region,
$ResourceGroupName="shadowsocks",
$SubscriptionID="<mySubscription>",
[switch]$delete
)
#Check PS Version - supports Powershell 6.1
if($PSVersionTable.GitCommitId -lt 6.1.0)
    {
        ThrowError -ExceptionMessage "Please update to the latest version of PowerShell 6 or ensure script was run with pwsh.exe"
    }
else {
    Write-Debug "PSVersion is $($PSVersionTable.PSVersion)"
}
#Check if Azure Modules are installed
if(!(Get-Module -ListAvailable -Name "Az.Accounts"))
    {
        ThrowError -ExceptionMessage "Ensure Azure Modules are Installed.  Try Install-Module -Name Az -scope CurrentUser"
    }
else {
    Write-Debug "Az Accounts module found"
}

Write-Debug -Message "Checking for authenticated session"

$session = Get-AzContext -ea 0
if (!($session)){
    Write-Debug -Message "No Session Found - Logging in"
    Login-AzAccount
    Set-AzContext -Subscription $SubscriptionID
}
elseif ($session.Subscription -ne $subscriptionID) {
    Write-Debug -Message "Setting Subscription Context to $($subscriptionId)"
    Set-AzContext -Subscription $SubscriptionID
}

if ($delete){
    Remove-AzResourceGroup -Name $ResourceGroupName -Force -Confirm:$false
    exit
}

Write-Debug -Message "Creating Resource Group if not exists..."
$resourceGroupObject = get-AzResourceGroup -Name $ResourceGroupName -Location $region -ea 0

if (!($resourceGroupObject))
    {
        $resourceGroupObject = New-AzResourceGroup -Name $ResourceGroupName -Location $region
}

$containerParams = @{
    Name = "shadowsocks"
    ResourceGroupName = $resourceGroupObject.ResourceGroupName
    Command = "/usr/local/bin/ssserver -k $($password) -m aes-256-cfb"
    Location = $resourceGroupObject.Location
    Image = "oddrationale/docker-shadowsocks"
    IpAddressType = "public"
    Port = 8388
}

$containerGroup = New-AzContainerGroup @containerParams


Write-Output $containerGroup.IpAddress

