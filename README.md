# container-vpn
Create a ShadowSocks SOCKS5 Proxy in an Azure Container Instance Container and run a secure SOCKSv5 connection from any Azure Datacenter!

# Dependencies
Azure [CLI](https://aka.ms/az-cli) and Bash/zsh
    OR
[PowerShell](https://github.com/powershell/powershell) >= 6.1 with [Azure](https://www.powershellgallery.com/packages/Az/1.4.0) Modules installed

[ShadowSocks Client](https://shadowsocks.org/en/download/clients.html)

# Easy Deploy!

Windows:
1. Clone this Repo with git
2. edit simple_deployment/quickdeploy.ps1 with your subscription ID
3. run simple_deployment/quickdeploy.ps1 -password <passsword> -region <region>
4. Connect your ShadowSocks client to the public IP address returned using your password from step 3 and aes-256-cfb
5. Configure your browser to use a socks proxy at 127.0.0.1:1080
6. run ./simple_deployment/quickdeploy.ps1 -delete to shut down the server

Linux:
1. Clone this Repo with git
2. edit simple_deployment/quickdeploy.sh with your subscription ID
3. run "bash quickdeploy.sh -p <password> <region>"
4. If ShadowSocks is installed, it will connect automatically
5. Configure your browser to use a SOCKS5 proxy at 127.0.0.1:1080
6. To disconnect run "bash simple_deployment/quickdeploy.sh -stop" to stop the local shadowsocks client and delete the container


# ToDos
 - Bash Quick Deployment
 - Coming Soon - Build your container from a webhook, and keep your password safe in a KeyVault where checked out at runtime!
   
