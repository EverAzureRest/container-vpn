# container-vpn
Create a ShadowSocks SOCKS5 Proxy in an Azure Container Instance Container and run a secure SOCKSv5 connection from any Azure Datacenter!

#About

[Azure Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/) is a small, burstable compute fabric that allows us to deploy our server in a state of ephimeral compute that can be brought up or destroyed at will

Using this platform for a SOCKS5 proxy server is perfect for those that need a quick connection outside their geographic region or need to escape prying eyes of Government or ISP

Azure Container Instances are billed on a per-second basis, therefore this will likely be a cheaper solution for most users who normally rely on monthly, paid VPN services

# Dependencies

[Azure](https://portal.azure.com)subscription

Azure [CLI](https://aka.ms/az-cli) and Bash/zsh
    OR
[PowerShell](https://github.com/powershell/powershell) >= 6.1 with [Azure](https://www.powershellgallery.com/packages/Az/1.4.0) Modules installed

[ShadowSocks Client](https://shadowsocks.org/en/download/clients.html)

# Easy Deploy!

Windows:
1. Clone this Repo with git
2. edit simple_deployment/quickdeploy.ps1 with your subscription ID
3. run ```pwsh.exe simple_deployment/quickdeploy.ps1 -password <passsword> -region <region>```
4. Connect your ShadowSocks client to the public IP address returned using your password from step 3 and aes-256-cfb
5. Configure your browser to use a socks proxy at 127.0.0.1:1080
6. run ```pwsh.exe simple_deployment/quickdeploy.ps1 -delete``` to shut down the server

Linux (may work on Mac - but untested):
1. Clone this Repo with git
2. edit simple_deployment/quickdeploy.sh with your subscription ID
3. run ```bash quickdeploy.sh -p <password> <region>```
4. If ShadowSocks is installed, it will connect automatically
5. Configure your browser to use a SOCKS5 proxy at 127.0.0.1:1080
6. To disconnect run ```bash simple_deployment/quickdeploy.sh -stop``` to stop the local shadowsocks client and delete the container

# ToDos
 - Coming Soon - Build your container from a webhook, and keep your password safe in a KeyVault where checked out at runtime!
   
#Credits

[Oddrationale](https://hub.docker.com/r/oddrationale/docker-shadowsocks) on [Docker Hub](https://hub.docker.com/) for the container image