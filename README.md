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

1. RSA est en cours de dépréciation :
   - Dans OpenSSH (version 8.8 sortie en 2021), la clé ssh-rsa a été désactivée par défaut, suite à l’usage du hash SHA-1, jugé obsolète et vulnérable
   - En parallèle, une dépréciation générale du SHA-1 dans les clés RSA est en cours sur plusieurs distributions

Sources :

- [Wikipédia OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) last update on 8 July 2025
- [Ubuntu 22.04 SSH the RSA key isn't working since upgrading from 20.04](https://askubuntu.com/questions/1409105/ubuntu-22-04-ssh-the-rsa-key-isnt-working-since-upgrading-from-20-04)

2. Performance, sécurité et taille inefficace
   - RSA nécessite des clés beaucoup plus longues pour atteindre une sécurité comparable aux algorithmes modernes. Cela se traduit par des performances moindres (vitesse de génération, signature, validation), surtout sur des systèmes contraints

Sources :

- [Comparing SSH Keys - RSA, DSA, ECDSA, or EdDSA?](https://goteleport.com/blog/comparing-ssh-keys/)
- [Wikipédia Elliptic-curve_cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography) last update on 30 August 2025

3. Vulnérabilité face aux avancées futures

- Les grandes évolutions en factorisation (classique ou quantique) pourraient compromettre RSA plus rapidement à long terme

Sources :

- [Comparing SSH Keys - RSA, DSA, ECDSA, or EdDSA?](https://www.strongdm.com/blog/comparing-ssh-keys) last update on 25 June 2025
- [OpenSSH 9.6p1: What is the best key type for the ssh-keygen command through the -t option?](https://itsfoss.community/t/openssh-9-6p1-what-is-the-best-key-type-for-the-ssh-keygen-command-through-the-t-option/12276) submitted on 1 Jul 2024
- [A Comparative Study of Classical and Post-Quantum Cryptographic Algorithms in the Era of Quantum Computing](https://arxiv.org/abs/2508.00832) submitted on 6 Jun 2025

=> RSA est encore reconnu, mais ses limites (SHA-1, taille, performance) et son avenir incertain en font un choix de moins en moins recommandé pour SSH.

##### Recommendation of another encryption algorithm

Un bon algorithme cryptographique repose sur plusieurs fondations essentielles : la sécurité, la performance, et la capacité à évoluer (c’est-à-dire la maturité/crypto-agilité assurée par une documentation active et une adoption pérenne) — comme le recommande le NIST.

Source : [NIST CSWP 39 second public draft, Considerations for Achieving Crypto Agility](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.39.2pd.pdf)

Résumé : Le NIST (National Institute of Standards and Technology), dans sa publication de juillet 2025, évoque explicitement que, pour un algorithme cryptographique à clé publique, la force de sécurité dépend des paramètres (sécurité), et que des contraintes de performances et de ressources doivent également être prises en compte (performance). De plus, il souligne la nécessité d’une agilité cryptographique — autrement dit, un algorithme mature et bien documenté permettant des transitions futures sans rupture brusque (maturité/documentation)

1. Ed25519 (EdDSA)
   - Sécurité robuste : Ed25519 offre un niveau de sécurité très élevé avec une clé compacte — meilleure densité de sécurité avec moins de bits
   - Performance : C’est l’algorithme le plus rapide sur tous les metrics (génération, signature, validation)
   - Implémentation plus simple, moins de failles : Le processus de génération d’une clé est simple (nombre aléatoire appliqué directement), contrairement à RSA qui a des points de fragilité liés à la génération de grands nombres premiers
   - Résistance aux vulnérabilités connues : Évite les failles des anciens algorithmes comme DSA ou ECDSA — aucune suspicion de portes dérobées comme certaines courbes NIST
   - Support mature : Ed25519 est supporté par OpenSSH depuis la version 6.5 (2014), et a été standardisé dans le protocole SSH
   - Adoption actuelle : En 2023, il est largement considéré comme la norme professionnelle pour les clés SSH

Sources :

- [Comparing SSH Keys - RSA, DSA, ECDSA, or EdDSA?](https://goteleport.com/blog/comparing-ssh-keys/)
- [Wikipédia Elliptic-curve_cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography) last update on 30 August 2025
- [It’s 2023. You Should Be Using an Ed25519 SSH Key](https://www.brandonchecketts.com/archives/its-2023-you-should-be-using-an-ed25519-ssh-key-and-other-current-best-practices) submitted on 10 September 2023
- [Why are ED25519 keys better than RSA](https://news.ycombinator.com/item?id=12575358)
- [How to generate the best SSH keys](https://www.keystash.io/guides/how-to-generate-the-best-ssh-keys.html) submitted on September 2022
- [Wikipédia Ssh-keygen](https://en.wikipedia.org/wiki/Ssh-keygen) last update on 16 August 2025
- [Wikipédia OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) last update on 8 July 2025
- [Wikipédia EdDSA](https://en.wikipedia.org/wiki/EdDSA) last update on 3 August 2025

2. ou ECDSA (avec précaution)
   - ECDSA utilise la cryptographie à courbe elliptique, ce qui permet des clés courtes pour une bonne sécurité
   - Mais certaines courbes (NIST P-256 etc.) ont soulevé des inquiétudes de fiabilité ou d’interventions possibles
   - Par conséquent, Ed25519 est à préférer à ECDSA, en particulier avec une courbe non NIST comme Curve25519.

Sources :

- [How to generate the best SSH keys](https://www.keystash.io/guides/how-to-generate-the-best-ssh-keys.html) submitted on September 2022
- [Wikipédia Elliptic-curve_cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography) last update on 30 August 2025

#### Generation paires clés SSH

```bash
    chmod +x setup_ssh_ed25519.sh
    ./setup_ssh_ed25519.sh
```

Notes :

- -a 100 : renforce la protection par passphrase (PBKDF).
- -o : format de clé moderne et sûr.
- -C : commentaire (souvent un email ou un label).

#### Agent SSH

```bash
    chmod +x start_ssh_agent.sh
    ./start_ssh_agent.sh
```

### Spawn des VMs

1. Depuis la WebUI

- Creation d'un groupe de ressource appelé test1
- Nommage de la VM en Tp1
- Choix des paramètres de Région, disponibilité etc
- Connection SSH (avec port 22 ouvert) à partir d'une clé publique existante généré depuis mon script setup_ssh_ed25519.sh utilisant l'algorithme ED25519. Récupération sous cat /Users/yduvignau/.ssh/id_ed25519.pub
- Création de la VM
- Récupération de l'ip publique de la VM
- Accès en SSH à la VM via : ssh azureuser@<public_ip_address>
- On arrive dans /home/azureuser de la VM

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
   - az account show --query id
   - Le provider azurerm de Terraform ne supporte que RSA (ssh-rsa) pour admin_ssh_key. Avec az vm create en CLI, Microsoft a déjà ajouté le support Ed25519, mais le provider Terraform ne l’a pas encore intégré (c’est une limitation connue).
   - ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_terraform -C "terraform_vm"
   - (base) yduvignau@MacBook-Pro-de-Yannis tp1 % ssh azureuser@<public_ip_address>
     kex_exchange_identification: Connection closed by remote host
     Connection closed by <public_ip_address> port 22
   - => Ajout d'une règle NSG pour SSH
   - terraform plan -out myplan
     terraform apply "myplan"
   - ssh -i ~/.ssh/id_rsa_terraform azureuser@<public_ip_address>

## TP2 : 'Aller plus loin avec Azure'

### Network Security Group

- ajout d'un fichier network.tf avec nsg, ssh et nic_nsg
- bonne pratique en sécurité : règle Deny all inbound pour bloquer explicitement tout le reste

```bash
  Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
  Outputs:
  public_ip = "<public_ip_address>"
```

-

```bash
  az vm show \
    --resource-group sandbox-rg2 \
    --name SampleVM \
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
    (base) yduvignau@MacBook-Pro-de-Yannis cloud_computing % ssh -A -i ~/.ssh/id_rsa_terraform azureuser@20.0.72.107
    ssh: connect to host 20.0.72.107 port 22: Connection refused
    (base) yduvignau@MacBook-Pro-de-Yannis cloud_computing % ssh -A -i ~/.ssh/id_rsa_terraform -p 2222 azureuser@20.0.72.107
    ssh: connect to host 20.0.72.107 port 2222: Operation timed out
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
Dans terraform.tfvars : dns_label  = "mon-vm-toto"
et dans variables.tf : 
```bash
variable "dns_label" {
  description = "Label DNS pour la IP publique (doit être en minuscules, chiffres et tirets, unique au sein du cluster régional)"
  type        = string
  default     = "" 
  validation {
    condition     = var.dns_label == "" || can(regex("^[a-z0-9-]{3,63}$", var.dns_label))
    error_message = "dns_label doit être vide ou respecter ^[a-z0-9-]{3,63}$ (minuscules, chiffres et tirets)."
  }
}
```

2. Ajouter un output custom à terraform apply
- Creation d'un fichier outputs.tf et rajoute d'un output du dns :
```bash
output "public_ip_fqdn" {
  description = "FQDN complet fourni par Azure (si domain_name_label renseigné)"
  value       = azurerm_public_ip.pip.fqdn
}
```

- ssh -A -i ~/.ssh/id_rsa_terraform azureuser@mon-vm-toto.uksouth.cloudapp.azure.com

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

- ajout de identity {
    type = "SystemAssigned"
  } dans ma config de vm pour créer une identité unique pour cette VM dans Azure Active Directory. Une fois la VM créée avec cette identité, votre data "azurerm_virtual_machine" pourra la trouver, et l'expression data.azurerm_virtual_machine.data.identity[0].principal_id fonctionnera correctement.

- Installation de azcopy
```bash
# Télécharger azcopy
wget https://aka.ms/downloadazcopy-v10-linux

# Décompresser l'archive
tar -xvf downloadazcopy-v10-linux

# Se déplacer dans le bon dossier (le nom peut légèrement varier)
cd azcopy_linux_amd64_*

# Déplacer l'exécutable pour qu'il soit accessible partout
sudo cp ./azcopy /usr/local/bin/
```

- C'est l'étape cruciale. Vous n'avez pas besoin de mot de passe ni de clé, car la VM va s'authentifier elle-même.
```bash
azureuser@SampleVM:~$ azcopy login --identity
INFO: Login with identity succeeded.
```

- Essayez d'envoyer un fichier vers le stockage. : 
```bash
echo "Test depuis la VM" > test-vm.txt 
```

- Ensuite, envoyez-le vers votre conteneur. L'argument --auth-mode login est très important, car il indique à la commande d'utiliser l'identité avec laquelle vous venez de vous connecter.
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

- Récupération
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

- Déterminez comment azcopy login --identity vous a authentifié :
L'authentification azcopy login --identity fonctionne grâce au service de métadonnées d'instance Azure (IMDS), qui est une API REST accessible uniquement depuis une VM Azure.
Quand vous lancez la commande, azcopy envoie une requête à une adresse IP spéciale (169.254.169.254) sur la VM. L'IMDS, qui reçoit cette requête, génère un jeton d'accès JWT (JSON Web Token) au nom de l'identité managée de la VM. Ce jeton est ensuite présenté par azcopy aux services Azure (comme le stockage) pour prouver son identité sans avoir besoin de secret ou de mot de passe. C'est un peu comme si la VM avait sa propre carte d'identité fournie par Azure.

- Requêtez un JWT d'authentification auprès du service que vous venez d'identifier, manuellement :
```bash
azureuser@SampleVM:~$ curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/' -H Metadata:true
{
  "access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkpZaEFjVFBNWl9MWDZEQmxPV1E3SG4wTmVYRSIsImtpZCI6IkpZaEFjVFBNWl9MWDZEQmxPV1E3SG4wTmVYRSJ9.eyJhdWQiOiJodHRwczovL3N0b3JhZ2UuYXp1cmUuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzQxMzYwMGNmLWJkNGUtNGM3Yy04YTYxLTY5ZTczY2RkZjczMS8iLCJpYXQiOjE3NTc5NDIyNTgsIm5iZiI6MTc1Nzk0MjI1OCwiZXhwIjoxNzU4MDI4OTU4LCJhaW8iOiJrMlJnWVBBcDNHcGRvWktlbkN2d2NSR0xPN01XQUE9PSIsImFwcGlkIjoiNmExM2YxODItMzJmZS00ZmYyLWFiZTEtYzUwM2JiY2NmNzExIiwiYXBwaWRhY3IiOiIyIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNDEzNjAwY2YtYmQ0ZS00YzdjLThhNjEtNjllNzNjZGRmNzMxLyIsImlkdHlwIjoiYXBwIiwib2lkIjoiYzI3Y2NiOWEtMTI4Yi00YWU3LWI3YmQtODhkMTA4NGU3ZjYwIiwicmgiOiIxLkFUc0F6d0EyUVU2OWZFeUtZV25uUE4zM01ZR21CdVRVODZoQ2tMYkNzQ2xKZXZFVkFRQTdBQS4iLCJzdWIiOiJjMjdjY2I5YS0xMjhiLTRhZTctYjdiZC04OGQxMDg0ZTdmNjAiLCJ0aWQiOiI0MTM2MDBjZi1iZDRlLTRjN2MtOGE2MS02OWU3M2NkZGY3MzEiLCJ1dGkiOiIwNFJLNS1Ram4wLVNMWm5iQS0tUUFBIiwidmVyIjoiMS4wIiwieG1zX2Z0ZCI6IjJLWTBHLTVVNGFEUTN6OFlTbC1wSnVFVERDTWtjNlAtTFA0aEZwYVdCQzhCZFd0emIzVjBhQzFrYzIxeiIsInhtc19pZHJlbCI6IjcgMjYiLCJ4bXNfbWlyaWQiOiIvc3Vic2NyaXB0aW9ucy81NzgwOWNkMC0xZjE2LTRjNWYtYmNiMC0yNWM4MjliNmVkNzUvcmVzb3VyY2Vncm91cHMvc2FuZGJveC1yZzIvcHJvdmlkZXJzL01pY3Jvc29mdC5Db21wdXRlL3ZpcnR1YWxNYWNoaW5lcy9TYW1wbGVWTSIsInhtc19yZCI6IjAuNDJMbFlCSml0QllTNGVBVUVsRHA5YlZidWUyMjc2UXY2Ym95bWsxNlFGRU9JWUhHWld4UHJueGU0VFJoMjZFTm1wNVZId0UiLCJ4bXNfdGRiciI6IkVVIn0.e0-7uilxznhFfzTb2r2nK86RpvSZ-Yeickk3-VqCCBxi_q3pGUeyC2a4dmlfEosWxPAqRSRozEAHfP7CesmKqIZmIUdt-YwvVaYy23nxnZKgk34sY4ETGgOZVW1bgUjMIGY3JJdkG9ND1xPB1apa6NK_jt3enmdtP_gweLt6IyLQVOhpjkQ0o1ql_nGkb8ZDimzCCMPwRFizGFJEHtLPuhytETJQCmOSX1a2ArUyqoy9BeQb2l0t_0hXmmncH9D_6y7P8Dr8BaoD6H7BvjQWjRIPaS_l3Z7GQccep4jgkOaFsZJ6MOcddCHq0wdNjIIOUKyrVR-eq2yb9vkFMDOu3g",
  "client_id":"6a13f182-32fe-4ff2-abe1-c503bbccf711",
  "expires_in":"86400",
  "expires_on":"1758028958",
  "ext_expires_in":"86399",
  "not_before":"1757942258",
  "resource":"https://storage.azure.com/",
  "token_type":"Bearer"
  }
```
- Comment l'IP 169.254.169.254 est-elle joignable ?
Cette adresse IP est une adresse link-local non routable sur internet. Elle n'existe pas sur votre réseau virtuel (VNet).
Le "truc", c'est que l'hyperviseur Azure (le logiciel qui gère votre VM sur le serveur physique) intercepte tout le trafic destiné à cette adresse IP spécifique. Au lieu d'envoyer la requête sur le réseau, il la redirige directement vers le service IMDS qui tourne sur l'hôte physique.
La table de routage de la VM contient une route par défaut qui envoie tout le trafic inconnu vers la passerelle du VNet, mais elle a aussi une route système implicite pour 169.254.169.254/32 qui pointe vers l'hôte. C'est ce qui garantit que la requête ne quitte jamais l'environnement sécurisé de l'hôte, rendant ce mécanisme très sûr.

- az vm nic list --resource-group rg --vm-name SampleVM