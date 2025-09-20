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