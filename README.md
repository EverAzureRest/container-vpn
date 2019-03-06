# container-vpn
Create a ShadowSocks SOCKS5 Proxy in an Azure Container Instance Container and run a secure SOCKSv5 connection from any Azure Datacenter!

# About

[Azure Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/) is a small, burstable compute fabric that allows us to deploy our proxy server in a state of ephimeral compute that can be brought up or destroyed at will without any lingering data.
In other words, a little slice of compute to run the remote side of the proxy without the need for any traditional server, hardware or networking requirements.  This is otherwise known as [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)

Using this platform for a [SOCKS5](https://en.wikipedia.org/wiki/SOCKS) proxy server is perfect for those that need a quick connection outside their geographic region or need to escape prying eyes of Governments or ISPs

Azure Container Instances are billed on a per-second basis, therefore this will likely be a cheaper solution for most users who rely on monthly, paid VPN services

# Dependencies

[git](https://git-scm.com)

[Azure](https://portal.azure.com) subscription.  Microsoft gives free 30-day trials for new accounts

Azure [CLI](https://aka.ms/az-cli) and Bash/zsh
    ***OR***
[PowerShell](https://github.com/powershell/powershell) >= 6.1 with [Azure](https://www.powershellgallery.com/packages/Az/1.4.0) Modules installed

[ShadowSocks Client](https://shadowsocks.org/en/download/clients.html)

A Text Editor like Vi, Nano, Notepad, [Notepad++](https://notepad-plus-plus.org/), or my personal favorite editor [Code](https://code.visualstudio.com/)

# Understanding Regions

Microsoft builds Azure Datacenters all over the world in pairs of Datacenters located around Geo-political [Regions](https://azure.microsoft.com/en-us/global-infrastructure/regions/).

It's good to understand where Azure Regions are located in order to know where you can proxy your connection to. 
If you want to proxy your connection to the US for example, you have many regions to choose from like WestUs, EastUS, EastUs2, SouthCentralUS, etc.

Luckily Azure makes it easy for us to figure out which regions the Azure service we wish to use is available in, which is covered in the next section.


# Steps for a Simple Deploy!

Make sure you authenticate your Azure client to Azure prior to these steps

***PowerShell:*** 
```powershell
Connect-AzAccount
```

***CLI:***
```bash
az login
```

Check if Azure Container Instances are available in the Region you want to deploy to:

***PowerShell:***
```powershell
(Get-AzResourceProvider -ProviderNamespace Microsoft.ContainerInstance)[0].locations
```

***CLI:***
```bash
az provider show --namespace Microsoft.ContainerInstance --query "resourceTypes[0].locations"
```

***Just remember to remove the spaces from the names of the Region when you deploy, i.e. East US 2 == eastus2***

To get your Subscription ID:

***PowerShell:*** 
```powershell
Get-AzSubscription
```

***CLI:***
```bash 
az account show
``` 

Either command will return all the Subscriptions that your account has access to.  The SubscriptionId field is a GUID value and will be copied into the script you run in step 4 of the deployment. You may want to copy and paste that value into a text editor to be referenced during step 4.

The deployment script will take that value and ensure we deploy to the correct subscription

## Windows:

1. Open PowerShell (pwsh.exe) and change to a directory that you can create new directories in. 
```powershell
PS> cd C:\Users\myusername\mydirectory
```

2. Clone this Repo into that folder with git
```
PS> git clone https://github.com/EverAzureRest/container-vpn.git
```

3. Change into the Repo Directory
```powershell
PS> cd container-vpn
```

4. edit ***simple_deployment/quickdeploy.ps1*** using a text editor, and where you see `$SubscriptionID="mySubscriptionGUID"` replace "mySubscriptionGUID" with your subscription Id, leaving the quotes - see the above section about retrieving your SubscriptionId.
We do this to ensure we are deploying to the desired Azure Subscription as it is possible to have many Subscriptions.
Make sure to **save your changes to the file before continuing**

5. In PowerShell run the script to deploy the server where `<password>` is your desired password to connect to the proxy server and `<region>` is the Azure Region you want to proxy your connection through
```powershell
simple_deployment/quickdeploy.ps1 -password <password> -region <region>
simple_deployment/quickdeploy.ps1 -password weakpassword -region eastasia
```

6. Connect your ShadowSocks client to the public IP address returned using your password from step 5 and aes-256-cfb cypher - options in the shadowsocks GUI

7. Configure your browser to use a ***SOCKS5*** proxy at 127.0.0.1:1080 - [Firefox Instructions](https://www.howtogeek.com/293213/how-to-configure-a-proxy-server-in-firefox/),  [Chrome Instructions](https://productforums.google.com/d/msg/chrome/9IDWpZ5-RAM/v68jStH77loJ)

8. To delete/stop the server, run in PowerShell:
```powershell
simple_deployment/quickdeploy.ps1 -delete
```

## Linux: (may work on Mac - but untested)

1. Open any bash or zsh shell terminal and change to a directory to clone the Repo into
```
cd ~/src
```

2. Clone this Repo with git
```bash
git clone https://github.com/EverAzureRest/container-vpn.git
```

3. Change into the Repo Directory
```
cd container-vpn
```

4. edit ***simple_deployment/quickdeploy.sh*** using a text editor, and where you see `export SUBSCRIPTION="mySubscriptionId"` replace "mySubscriptionId" with your subscription Id, leaving the quotes - see above about retreiving your SubscriptionId.
We do this to make sure you are deploying to the right Azure Subscription as it is possible to have many Subscriptions.
Make sure to **save your changes to the file before continuing**

5. run the script to deploy the server where `<password>` is your desired password to connect to the proxy server and `<region>` is the Azure Region you want to proxy your connection through.
```bash
bash simple_deploy/quickdeploy.sh -p <password> <region>
bash simple_deploy/quickdeploy.sh -p weakpassword japaneast
```

6. If ShadowSocks is installed, it will connect automatically

7. Configure your browser to use a ***SOCKS5*** proxy at 127.0.0.1:1080 - [Firefox Instructions](https://www.howtogeek.com/293213/how-to-configure-a-proxy-server-in-firefox/), [Chrome Instructions](https://productforums.google.com/d/msg/chrome/9IDWpZ5-RAM/v68jStH77loJ)

8. To disconnect the client and delete the server, run 
```bash 
bash simple_deployment/quickdeploy.sh -stop
```


# ToDos
 - Webhook integration, and keep your password safe in a KeyVault where checked out at runtime!
 - Integrate private container registry and build from dockerfile
   
# Credits

[Oddrationale](https://hub.docker.com/r/oddrationale/docker-shadowsocks) on [Docker Hub](https://hub.docker.com/) for the container image