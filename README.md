# container-vpn
Create a ShadowSocks SOCKS5 Proxy in an Azure Container Instance Container and run a secure SOCKSv5 connection from any Azure Datacenter!

# About

[Azure Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/) is a small, burstable compute fabric that allows us to deploy our proxy server in a state of ephimeral compute that can be brought up or destroyed at will without any lingering data.  In other words, a little slice of compute to run the remote side of the proxy without the need for any traditional server, hardware or networking requirements.  This is otherwise known as [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)

Using this platform for a [SOCKS5](https://en.wikipedia.org/wiki/SOCKS) proxy server is perfect for those that need a quick connection outside their geographic region or need to escape prying eyes of Governments or ISPs

Azure Container Instances are billed on a per-second basis, therefore this will likely be a cheaper solution for most users who rely on monthly, paid VPN services

# Dependencies

[git](https://git-scm.com)

[Azure](https://portal.azure.com) subscription.  Microsoft gives free 30-day trials for new accounts

Azure [CLI](https://aka.ms/az-cli) and Bash/zsh
    OR
[PowerShell](https://github.com/powershell/powershell) >= 6.1 with [Azure](https://www.powershellgallery.com/packages/Az/1.4.0) Modules installed

[ShadowSocks Client](https://shadowsocks.org/en/download/clients.html)

# Understanding Regions

Microsoft builds Azure Datacenters all over the world in pairs of Datacenters located around Geo-political [Regions](https://azure.microsoft.com/en-us/global-infrastructure/regions/).
It's good to understand where Azure Regions are located in order to know where you can proxy your connection to. 
If you want to proxy your connection to the US for example, you have many regions to choose from like WestUs, EastUS, EastUs2, SouthCentralUS, etc. 
Luckily Azure makes it easy for us to figure out which regions the Azure service we wish to use is available in, which is covered in the next section.

***Just remember to remove the spaces from the names of the Region when you deploy, i.e. East US 2 == eastus2***

# Steps for a Simple Deploy!

Make sure you authenticate your Azure client to Azure prior to these steps
***PowerShell:*** ```Connect-AzAccount```
***CLI:*** ```az login```

Check if Azure Container Instances are available in the Region you want to deploy to:

***PowerShell:*** ```(Get-AzResourceProvider -ProviderNamespace Microsoft.ContainerInstance)[0].locations```
***CLI:*** ```az provider show --namespace Microsoft.ContainerInstance --query "resourceTypes[0].locations"```

***Just remember to remove the spaces from the names of the Region when you deploy, i.e. East US 2 == eastus2***

To get your Subscription ID:
***PowerShell:*** ```get-azsubscription```

***CLI:*** ```az account show``` 

Either command will return all the Subscriptions that your account has access to.  The SubscriptionId field is a GUID value and will be copied into the script you run in step 2 of the deployment

The deployment script will take that value and ensure we deploy to the correct subscription

Windows:
1. Clone this Repo into a folder somewhere on your computer with git
    ```git clone https://github.com/EverAzureRest/container-vpn.git```
2. edit ***simple_deployment/quickdeploy.ps1*** using a text editor with your subscription ID - see above about how to get that.  We do this to make sure you are deploying to the right Azure Subscription as it is possible to have many Subscriptions.

3. run ```pwsh.exe simple_deployment/quickdeploy.ps1 -password <passsword> -region <region>```

4. Connect your ShadowSocks client to the public IP address returned using your password from step 3 and aes-256-cfb

5. Configure your browser to use a ***SOCKS5*** proxy at 127.0.0.1:1080 - [Firefox](https://www.howtogeek.com/293213/how-to-configure-a-proxy-server-in-firefox/) [Chrome](https://productforums.google.com/d/msg/chrome/9IDWpZ5-RAM/v68jStH77loJ)

6. run ```pwsh.exe simple_deployment/quickdeploy.ps1 -delete``` to shut down the server

Linux (may work on Mac - but untested):
1. Clone this Repo with git
    ```git clone https://github.com/EverAzureRest/container-vpn.git```

2. edit simple_deployment/quickdeploy.sh with your subscription ID - see above about how to get that.  We do this to make sure you are deploying to the right Azure Subscription as it is possible to have many Subscriptions.

3. run ```bash quickdeploy.sh -p <password> <region>```

4. If ShadowSocks is installed, it will connect automatically

5. Configure your browser to use a SOCKS5 proxy at 127.0.0.1:1080 - [Firefox](https://www.howtogeek.com/293213/how-to-configure-a-proxy-server-in-firefox/) [Chrome](https://productforums.google.com/d/msg/chrome/9IDWpZ5-RAM/v68jStH77loJ)

6. To disconnect run ```bash simple_deployment/quickdeploy.sh -stop``` to stop the local shadowsocks client and delete the container

# ToDos
 - Webhook integration, and keep your password safe in a KeyVault where checked out at runtime!
 - Integrate private container registry and build from dockerfile
   
# Credits

[Oddrationale](https://hub.docker.com/r/oddrationale/docker-shadowsocks) on [Docker Hub](https://hub.docker.com/) for the container image