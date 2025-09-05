# M1 Cloud Computing - Azure DevOps
[URL DOC TP](https://m1cloud.hita.wtf/)

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

Résumé  : Le NIST (National Institute of Standards and Technology), dans sa publication de juillet 2025, évoque explicitement que, pour un algorithme cryptographique à clé publique, la force de sécurité dépend des paramètres (sécurité), et que des contraintes de performances et de ressources doivent également être prises en compte (performance). De plus, il souligne la nécessité d’une agilité cryptographique — autrement dit, un algorithme mature et bien documenté permettant des transitions futures sans rupture brusque (maturité/documentation)

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
    - (base) yduvignau@MacBook-Pro-de-Yannis tp2 % ssh azureuser@<public_ip_address>
        kex_exchange_identification: Connection closed by remote host
        Connection closed by <public_ip_address> port 22
    - => Ajout d'une règle NSG pour SSH
    - terraform plan -out myplan 
        terraform apply "myplan"
    - ssh -i ~/.ssh/id_rsa_terraform azureuser@<public_ip_address>

## TP2 : 'Aller plus loin avec Azure'