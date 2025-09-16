# M1 Cloud Computing - Azure DevOps

[URL DOC TP - m1cloud](https://m1cloud.hita.wtf/)

Rendu : duvignau,[cloud-computing-azure-devops](https://github.com/yannisduvignau/cloud-computing-azure-devops)

## TP1 : 'Azure first steps'

### Prerequisites

1. How to install Azure CLI on macOS

```bash
    brew update && brew install azure-cli
```

2. How to install Terraform on macOS
   HashiCorp tap

```bash
    brew tap hashicorp/tap
```

Terraform from hashicorp/tap/terraform

```bash
    brew install hashicorp/tap/terraform
```

#### Encryption algorithm for generating an SSH key pair

##### Why 'vous n'utiliserez PAS RSA'

1. RSA is being depreciation :
   - In OpenSSH (version 8.8 released in 2021), the SSH-RSA key was deactivated by default, following the use of the Hash Sha-1, deemed obsolete and vulnerable
   - In parallel, a general depreciation of the SHA-1 in the RSA keys is underway on several distributions

Sources :
- [Wikipédia OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) last update on 8 July 2025
- [Ubuntu 22.04 SSH the RSA key isn't working since upgrading from 20.04](https://askubuntu.com/questions/1409105/ubuntu-22-04-ssh-the-rsa-key-isnt-working-since-upgrading-from-20-04)

2. Ineffective performance, safety and size
   - RSA requires much longer keys to reaching security comparable to modern algorithms. This results in lower performance (generation speed, signature, validation), especially on forced systems

Sources :
- [Comparing SSH Keys - RSA, DSA, ECDSA, or EdDSA?](https://goteleport.com/blog/comparing-ssh-keys/)
- [Wikipédia Elliptic-curve_cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography) last update on 30 August 2025

3. Vulnerability in the face of future advances

- Large developments in factorization (classic or quantum) could compromise RSA faster in the long term

Sources :
- [Comparing SSH Keys - RSA, DSA, ECDSA, or EdDSA?](https://www.strongdm.com/blog/comparing-ssh-keys) last update on 25 June 2025
- [OpenSSH 9.6p1: What is the best key type for the ssh-keygen command through the -t option?](https://itsfoss.community/t/openssh-9-6p1-what-is-the-best-key-type-for-the-ssh-keygen-command-through-the-t-option/12276) submitted on 1 Jul 2024
- [A Comparative Study of Classical and Post-Quantum Cryptographic Algorithms in the Era of Quantum Computing](https://arxiv.org/abs/2508.00832) submitted on 6 Jun 2025

=> RSA is still recognized, but its limits (SHA-1, size, performance) and its uncertain future make it a choice less and less recommended for SSH.

##### Recommendation of another encryption algorithm

A good cryptographic algorithm is based on several essential foundations: security, performance, and the ability to evolve (that is to say maturity/crypto-actility ensured by active documentation and sustainable adoption)-as the NIST recommends.

Source : [NIST CSWP 39 second public draft, Considerations for Achieving Crypto Agility](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.39.2pd.pdf)


Summary: The NIST (National Institute of Standards and Technology), in its publication of July 2025, explicitly evokes that, for a public cryptographic algorithm, the security force depends on the parameters (security), and that the constraints of performance and resources must also be taken into account (performance). In addition, he highlights the need for cryptographic agility -in other words, a mature and well -documented algorithm allowing future transitions without abrupt break (maturity/documentation)

1. Ed25519 (EdDSA)
   - Robust safety: ED25519 offers a very high level of safety with a compact key - better security density with less bits
   - Performance: this is the fastest algorithm on all Metrics (generation, signature, validation)
   - Simpler implementation, fewer faults: the process of generating a key is simple (random number applied directly), unlike RSA which has fragile points linked to the generation of large prime numbers
   - Resistance to known vulnerabilities: avoids flaws of ancient algorithms like DSA or ECDSA -no suspicion of stolen doors like certain NIST curves
   - Mature support: ED25519 has been supported by OpenSSH since version 6.5 (2014), and has been standardized in the SSH protocol
   - Current adoption: in 2023, it was widely considered as the professional standard for SSH keys

Sources :
- [Comparing SSH Keys - RSA, DSA, ECDSA, or EdDSA?](https://goteleport.com/blog/comparing-ssh-keys/)
- [Wikipédia Elliptic-curve_cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography) last update on 30 August 2025
- [It’s 2023. You Should Be Using an Ed25519 SSH Key](https://www.brandonchecketts.com/archives/its-2023-you-should-be-using-an-ed25519-ssh-key-and-other-current-best-practices) submitted on 10 September 2023
- [Why are ED25519 keys better than RSA](https://news.ycombinator.com/item?id=12575358)
- [How to generate the best SSH keys](https://www.keystash.io/guides/how-to-generate-the-best-ssh-keys.html) submitted on September 2022
- [Wikipédia Ssh-keygen](https://en.wikipedia.org/wiki/Ssh-keygen) last update on 16 August 2025
- [Wikipédia OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) last update on 8 July 2025
- [Wikipédia EdDSA](https://en.wikipedia.org/wiki/EdDSA) last update on 3 August 2025

2. or ECDSA (carefully)
   - ECDSA uses elliptical curve cryptography, which allows short keys for good safety
   - But certain curves (NIST P-256 etc.) have raised concerns of reliability or possible interventions
   - Consequently, ED25519 is to be preferred in ECDSA, in particular with a non -Nist curve like curve25519.

Sources :
- [How to generate the best SSH keys](https://www.keystash.io/guides/how-to-generate-the-best-ssh-keys.html) submitted on September 2022
- [Wikipédia Elliptic-curve_cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography) last update on 30 August 2025

#### Generation SSH key pairs

```bash
    chmod +x ./helpers/setup_ssh_ed25519.sh
    ./helpers/setup_ssh_ed25519.sh
```

Notes :
- -a 100 : Strengthens protection by passphrase (PBKDF).
- -o : Modern and safe key format.
- -C : Comment (often an email or a label).

#### Agent SSH

```bash
    chmod +x ./helpers/start_ssh_agent.sh
    ./helpers/start_ssh_agent.sh
```

ssh-agent -s : This order starts the SSH agent. The agent is a small program that turns in the background and keeps in memory the private key in a secure manner. It avoids having to retype the password from the key to each connection. The command only shows the environment variables necessary to communicate with this agent.
The agent takes care of authentication for all the following SSH connections, without asking the password.

### Spawn des VMs

1. From WebUI

- Creation of a resource group called test1
- Namage of the VM in TP1
- Choice of regional parameters, availability, etc.
- SSH Connection (with Port 22 Open) from an existing public key generated from my Setup_SSH_ED25519.sh script using the ED25519 algorithm. Recovery under cat /users/yduvignau/.ssh/id_ed25519.pub
- Creation of the VM
- Recovery of the Public IP of the VM
- Access in SSH to VM via: ssh azureuser@<public_ip_address>
- We arrive in /home/azureuser of the VM

2. az : a programmatic approach

- az login
- To list the Azure region available : az account list-locations --output table
- Search on https://learn.microsoft.com/en-us/training/modules/manage-virtual-machines-with-azure-cli/2-create-a-vm
- az vm create \
  --resource-group "[sandbox resource group name]" \
  --location uksouth \
  --name SampleVM \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_ed25519.pub
  --verbose
- chmod +x create_azure_vm.sh
- ./create_azure_vm.sh or ./create_azure_vm.sh myResourceGroup MyVM azureuser ~/.ssh/id_ed25519.pub
- problem avec size : az vm list-sizes --location uksouth -o table
- az interactive
- ./create_azure_vm.sh

```bash
azureuser@SampleVM:~$ systemctl status walinuxagent.service
Warning: The unit file, source configuration file or drop-ins of walinuxagent.service changed on disk. Run 'systemctl daemon-reload' to reload units.
● walinuxagent.service - Azure Linux Agent
     Loaded: loaded (/lib/systemd/system/walinuxagent.service; enabled; vendor preset: enabled)
    Drop-In: /run/systemd/system.control/walinuxagent.service.d
             └─50-CPUAccounting.conf, 50-MemoryAccounting.conf
     Active: active (running) since Fri 2025-09-05 11:02:08 UTC; 4min 43s ago
   Main PID: 753 (python3)
      Tasks: 7 (limit: 1009)
     Memory: 44.9M
        CPU: 2.624s
     CGroup: /system.slice/walinuxagent.service
             ├─ 753 /usr/bin/python3 -u /usr/sbin/waagent -daemon
             └─1050 python3 -u bin/WALinuxAgent-2.14.0.1-py3.12.egg -run-exthandlers
```

```bash
azureuser@SampleVM:~$ systemctl status cloud-init.service
● cloud-init.service - Cloud-init: Network Stage
     Loaded: loaded (/lib/systemd/system/cloud-init.service; enabled; vendor preset: enabled)
     Active: active (exited) since Fri 2025-09-05 11:02:07 UTC; 5min ago
   Main PID: 505 (code=exited, status=0/SUCCESS)
        CPU: 1.126s
```

3. Terraforming infrastructures
```bash
   (base) yduvignau@MacBook-Pro-de-Yannis tp1 % ssh azureuser@<public_ip_address>
   kex_exchange_identification: Connection closed by remote host
   Connection closed by <public_ip_address> port 22
```
   - => Adding a NSG rule for SSH
   - terraform plan -out myplan
     terraform apply "myplan"
   - ssh azureuser@<public_ip_address>

## TP2 : 'Aller plus loin avec Azure'

### Network Security Group

- Adding a network.tf file with NSG, SSH and Nic_NSG

```bash
  Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
  Outputs:
  public_ip = "<public_ip_address>"
```

```bash
  az vm show \
    --resource-group sandbox-rg-tp2 \
    --name SampleVM-TP2 \
    --show-details \
    -o jsonc
```

```bash
{
  "diagnosticsProfile": {
    "bootDiagnostics": {
      "enabled": false
    }
  },
  "etag": "\"1\"",
  "extensionsTimeBudget": "PT1H30M",
  "fqdns": "",
  "hardwareProfile": {
    "vmSize": "Standard_B1s"
  },
  "id": "/subscriptions/<subscription_id>/resourceGroups/sandbox-rg2/providers/Microsoft.Compute/virtualMachines/SampleVM",
  "location": "uksouth",
  "macAddresses": "60-45-BD-14-11-17",
  "name": "SampleVM",
  "networkProfile": {
    "networkInterfaces": [
      {
        "id": "/subscriptions/<subscription_id>/resourceGroups/sandbox-rg2/providers/Microsoft.Network/networkInterfaces/SampleVM-nic",
        "primary": true,
        "resourceGroup": "sandbox-rg2"
      }
    ]
  },
  "osProfile": {
    "adminUsername": "azureuser",
    "allowExtensionOperations": true,
    "computerName": "SampleVM",
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      "patchSettings": {
        "assessmentMode": "ImageDefault",
        "patchMode": "ImageDefault"
      },
      "provisionVMAgent": true,
      "ssh": {
        "publicKeys": [
          {
            "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAIpXDkt4YH30PB31AdSO/hP1J+oUrNm8AcSFE75ZreaEAsBx3amMTtQ9XkXIAO6HKdecuEFp8w3pBP5yaWqeBH+xXXQ5ImMEOUihA9CJ4ioE2Fyfvwv4JX4SJ1jG6Yt9Rj2owqD58IdeSlmbIIXIY+bLp4BLg82q0ml6sSy4vjSuheFvlpgDAYC1TGfKO6oRmVJLtuD2teFYascB3ieILg7qNU9qjWwXk1MTgyh1nci5GesQjHDFl9umugp0ac2fE9NHVZykA5T2XBHq5Rqy6wRH1QIHAuCDQauou0iJgMEljFDGnl8o6eNcxCEtxgO1Gfj5GnafKyefrPquZy9SkiWJi3Tn1YepZl14WU7+/npSbXFRHuS+6/D9i8SL+1fttcd29Srje+IEfrAgylrh6WXe5JtZIC37BK261R+fjLah7zCwnA/dne6h9jdFw8IHTqydVtFgYcr8cjAAjyZLoVoSs03GYi/0ueYrX+Gmv2c5vhSs6sTLwQCc5G21j+Fl6+DOmzT6/8cj4VCv4YFf+EN/2DglsEE0CegWoiaPXjx3tDZTbAvwnfTcmSHvtCOSDtPPtCO8ScMNgfjGOozfkUP8qtM1WOI2+I9p3+Xtf0AT28iqreDx1B6agsEzIql4GI9sOtuvEYrcweMzL/2VT195z7ccRZ/ycwKMKcRrXlw== terraform_vm\n",
            "path": "/home/azureuser/.ssh/authorized_keys"
          }
        ]
      }
    },
    "requireGuestProvisionSignal": true,
    "secrets": []
  },
  "powerState": "VM running",
  "priority": "Regular",
  "privateIps": "10.0.1.4",
  "provisioningState": "Succeeded",
  "publicIps": "<public_ip_address>",
  "resourceGroup": "sandbox-rg2",
  "storageProfile": {
    "dataDisks": [],
    "imageReference": {
      "exactVersion": "20.04.202505200",
      "offer": "0001-com-ubuntu-server-focal",
      "publisher": "Canonical",
      "sku": "20_04-lts",
      "version": "latest"
    },
    "osDisk": {
      "caching": "ReadWrite",
      "createOption": "FromImage",
      "deleteOption": "Detach",
      "diskSizeGB": 30,
      "managedDisk": {
        "id": "/subscriptions/<subscription_id>/resourceGroups/sandbox-rg2/providers/Microsoft.Compute/disks/vm-os-disk",
        "resourceGroup": "sandbox-rg2",
        "storageAccountType": "Standard_LRS"
      },
      "name": "vm-os-disk",
      "osType": "Linux",
      "writeAcceleratorEnabled": false
    }
  },
  "tags": {},
  "timeCreated": "2025-09-06T11:01:48.9358165+00:00",
  "type": "Microsoft.Compute/virtualMachines",
  "vmId": "532e5f29-8b51-4372-a48c-0a9aaa180daf"
}
```
- sudo nano /etc/ssh/sshd_config
    #Port 22
    Port 2222
    sudo systemctl restart sshd
```bash
    azureuser@SampleVM:~$ systemctl status sshd
    ● ssh.service - OpenBSD Secure Shell server
        Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
        Active: active (running) since Sat 2025-09-06 11:39:30 UTC; 34s ago
        Docs: man:sshd(8)
                man:sshd_config(5)
        Process: 1722 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
    Main PID: 1723 (sshd)
        Tasks: 1 (limit: 1063)
        Memory: 1.0M
        CGroup: /system.slice/ssh.service
                └─1723 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups

    Sep 06 11:39:30 SampleVM systemd[1]: Starting OpenBSD Secure Shell server...
    Sep 06 11:39:30 SampleVM sshd[1723]: Server listening on 0.0.0.0 port 2222.
    Sep 06 11:39:30 SampleVM sshd[1723]: Server listening on :: port 2222.
    Sep 06 11:39:30 SampleVM systemd[1]: Started OpenBSD Secure Shell server.
```

```bash
    (base) yduvignau@MacBook-Pro-de-Yannis cloud_computing % ssh azureuser@<public_ip_address>
    ssh: connect to host <public_ip_address> port 22: Connection refused
    (base) yduvignau@MacBook-Pro-de-Yannis cloud_computing % ssh -p 2222 azureuser@<public_ip_address>
    ssh: connect to host <public_ip_address> port 2222: Operation timed out
```

### Un ptit nom DNS
1. Adapter le plan Terraform
```bash
resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.dns_label
}
```
In terraform.tfvars : dns_label  = "mon-vm-toto"
and in variables.tf : 
```bash
variable "dns_label" {
  description = "DNS label for public IP (must be in tiny, figures and dashes, unique within the regional cluster)"
  type        = string
  default     = "" 
  validation {
    condition     = var.dns_label == "" || can(regex("^[a-z0-9-]{3,63}$", var.dns_label))
    error_message = "dns_label must be empty or respect ^[a-z0-9-]{3,63}$ (tiny, figures and dashes)."
  }
}
```

2. Add a custom output to terraform apply
- Creation of an OUTPUTS.TF file and adds an output of the DNS:
```bash
output "public_ip_fqdn" {
  description = "Full fqdn provided by Azure (if domain_name_label entered)"
  value       = azurerm_public_ip.pip.fqdn
}
```

- ssh azureuser@mon-vm-toto.uksouth.cloudapp.azure.com

### Blob Storage
- création d'un fichier storage.tf
- rajout de 2 outputs : 
```bash
output "storage_account_primary_key" {
  value = azurerm_storage_account.storage.primary_access_key
}

output "storage_container_url" {
  value = azurerm_storage_container.container.id
}
```

- add identity {
    type = "SystemAssigned"
  } 
  In the VM config to create a unique identity for this VM in Azure Active Directory. Once the VM is created with this identity, your data "azurerm_virtual_machine" can find it, and the expression data.azurerm_virtual_machine.data.identity[0].principal_id will work properly.

- Installation of azcopy
```bash
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
cd azcopy_linux_amd64_*
sudo cp ./azcopy /usr/local/bin/
```

- This is the crucial step. You don't need password or key, because the VM will authenticate itself.
```bash
azureuser@SampleVM:~$ azcopy login --identity
INFO: Login with identity succeeded.
```

- Try sending a file to storage. : 
```bash
echo "Test depuis la VM" > test-vm.txt 
```

- Then send it to your container. The argument --auth-mode login is very important, because it indicates that it is up to the order to use the identity with which you have just connected.
```bash
azcopy copy 'test-vm.txt' 'https://mystorageacct12345607.blob.core.windows.net/mycontainer/'
```

```bash
INFO: Scanning...
INFO: Autologin not specified.
INFO: Authenticating to destination using Azure AD
INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

Job 0f8c6e57-26a4-644c-67de-54c3d9124f21 has started
Log file is located at: /home/azureuser/.azcopy/0f8c6e57-26a4-644c-67de-54c3d9124f21.log

100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total, 2-sec Throughput (Mb/s): 0.0001


Job 0f8c6e57-26a4-644c-67de-54c3d9124f21 summary
Elapsed Time (Minutes): 0.0333
Number of File Transfers: 1
Number of Folder Property Transfers: 0
Number of Symlink Transfers: 0
Total Number of Transfers: 1
Number of File Transfers Completed: 1
Number of Folder Transfers Completed: 0
Number of File Transfers Failed: 0
Number of Folder Transfers Failed: 0
Number of File Transfers Skipped: 0
Number of Folder Transfers Skipped: 0
Number of Symbolic Links Skipped: 0
Number of Hardlinks Converted: 0
Number of Special Files Skipped: 0
Total Number of Bytes Transferred: 18
Final Job Status: Completed
```

- Recovery
```bash
azcopy copy 'https://mystorageacct12345607.blob.core.windows.net/mycontainer/test-vm.txt' 'test-vm_depuis_azure.txt'
```
```bash
INFO: Scanning...
INFO: Autologin not specified.
INFO: Authenticating to source using Azure AD
INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

Job 46c3aa4e-8c09-a546-7e29-c480e97c9e74 has started
Log file is located at: /home/azureuser/.azcopy/46c3aa4e-8c09-a546-7e29-c480e97c9e74.log

100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total, 2-sec Throughput (Mb/s): 0.0001


Job 46c3aa4e-8c09-a546-7e29-c480e97c9e74 summary
Elapsed Time (Minutes): 0.0334
Number of File Transfers: 1
Number of Folder Property Transfers: 0
Number of Symlink Transfers: 0
Total Number of Transfers: 1
Number of File Transfers Completed: 1
Number of Folder Transfers Completed: 0
Number of File Transfers Failed: 0
Number of Folder Transfers Failed: 0
Number of File Transfers Skipped: 0
Number of Folder Transfers Skipped: 0
Number of Symbolic Links Skipped: 0
Number of Hardlinks Converted: 0
Number of Special Files Skipped: 0
Total Number of Bytes Transferred: 18
Final Job Status: Completed

azureuser@SampleVM:~$ ls
azcopy_linux_amd64_10.30.1  downloadazcopy-v10-linux  test-vm.txt  test-vm_depuis_azure.txt
```
```bash
azureuser@SampleVM:~$ cat test-vm_depuis_azure.txt
Test depuis la VM
```

- Determine how azcopy login --identity authenticated you:
Authentication azcopy login --identity works thanks to the Azure (IMDS) metadata service, which is a REST API accessible only from an Azure VM.
When you launch the command, Azcopy sends a request to a special IP address (<public_ip_address>) on the VM. The IMDS, which receives this request, generates an access token JWT (JSON Web Token) in the name of the managed identity of the VM. This token is then presented by Azcopy to the Azure services (such as storage) to prove his identity without the need for secrets or password. It is a bit as if the VM had its own identity card provided by Azure.

- Request an authentication jwt to the service you have just identified, manually:
```bash
azureuser@SampleVM:~$ curl 'http://<public_ip_address>/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/' -H Metadata:true
{
  "access_token":<access_token>,
  "client_id":<client_id>,
  "expires_in":"86400",
  "expires_on":"1758028958",
  "ext_expires_in":"86399",
  "not_before":"1757942258",
  "resource":"https://storage.azure.com/",
  "token_type":"Bearer"
  }
```
- How is the IP <public_ip_address> can it be reached?
This IP address is an unrelated Link-Local address on the Internet. It does not exist on your virtual network (VNET).
The "thing" is that the Azure hypervisor (the software that manages your VM on the physical server) intercepts all the traffic intended for this specific IP address. Instead of sending the request to the network, he redirects it directly to the IMDS service which turns on the physical host.
The VM routing table contains a default road which sends all the unknown traffic to the Vnet bridge, but it also has an implicit system for <public_ip_Address>/32 which points to the host. This is what guarantees that the request never leaves the secure environment of the host, making this mechanism very safe.

- az vm nic list --resource-group sandbox-rg2 --vm-name SampleVM

### Monitoring (monitoring CPU et RAM)

- The Action Group (azurerm_monitor_action_group) : He defines what to do when an alert is triggered. Here is "sending an email".

- The alert rule (azurerm_monitor_metric_alert) : It links a resource (your VM) to a condition (CPU> 70%) and a group of shares.

- curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
- CPU : az monitor metric-alert list --resource-group sandbox-rg2 --output table
- RAM : az monitor scheduled-query list --resource-group sandbox-rg2 --output table

- Trigger of a stress of the VM : 
sudo apt update && sudo apt install stress-ng -y
stress-ng --cpu 1 --cpu-load 90 --timeout 10m
stress-ng --vm 1 --vm-bytes 1500M --timeout 10m

- az monitor activity-log list \
    --resource-group sandbox-rg2 \
    --start-time $(date --utc --iso-8601=seconds -d "1 hour ago") \
    --query "[?category.value=='Alert' && contains(properties.description, 'Fired')].{Time:eventTimestamp, AlertName:properties.alertRule, Status:status.value}" \
    --output table
```bash
2025-09-15T14:30:15.123456+00:00	Alert-VM-High-CPU	Succeeded
2025-09-15T14:35:45.987654+00:00	Alert-VM-Low-Memory	Succeeded
```

### Vault
- az keyvault secret show \
  --name "kv-tp2-1n4hf7cq" \
  --vault-name "tp2-super-secret-1n4hf7cq"