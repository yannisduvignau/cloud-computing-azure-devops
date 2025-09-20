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
  "fqdns": "mon-vm-toto.uksouth.cloudapp.azure.com",
  "hardwareProfile": {
    "vmSize": "Standard_B1s"
  },
  "id": "/subscriptions/<subscription_id>/resourceGroups/sandbox-rg-tp2/providers/Microsoft.Compute/virtualMachines/SampleVM-TP2",
  "identity": {
    "principalId": "<principal_identity_id>",
    "tenantId": "<tenant_identity_id>",
    "type": "SystemAssigned"
  },
  "location": "uksouth",
  "macAddresses": "<mac_adress>",
  "name": "SampleVM-TP2",
  "networkProfile": {
    "networkInterfaces": [
      {
        "id": "/subscriptions/<subscription_id>/resourceGroups/sandbox-rg-tp2/providers/Microsoft.Network/networkInterfaces/SampleVM-TP2-nic",
        "primary": true,
        "resourceGroup": "sandbox-rg-tp2"
      }
    ]
  },
  "osProfile": {
    "adminUsername": "azureuser",
    "allowExtensionOperations": true,
    "computerName": "SampleVM-TP2",
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
            "keyData": "<ssh_key>",
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
  "publicIps": "<public_ip>",
  "resourceGroup": "sandbox-rg-tp2",
  "resources": [
    {
      "autoUpgradeMinorVersion": true,
      "enableAutomaticUpgrade": false,
      "id": "/subscriptions/<subscription_id>/resourceGroups/sandbox-rg-tp2/providers/Microsoft.Compute/virtualMachines/SampleVM-TP2/extensions/OmsAgentForLinux",
      "location": "uksouth",
      "name": "OmsAgentForLinux",
      "provisioningState": "Succeeded",
      "publisher": "Microsoft.EnterpriseCloud.Monitoring",
      "resourceGroup": "sandbox-rg-tp2",
      "settings": {
        "workspaceId": "<workspace_setting_id>"
      },
      "suppressFailures": false,
      "tags": {},
      "typeHandlerVersion": "1.14",
      "typePropertiesType": "OmsAgentForLinux"
    }
  ],
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
        "id": "/subscriptions/<subscription_id>/resourceGroups/sandbox-rg-tp2/providers/Microsoft.Compute/disks/vm-os-disk",
        "resourceGroup": "sandbox-rg-tp2",
        "storageAccountType": "Standard_LRS"
      },
      "name": "vm-os-disk",
      "osType": "Linux",
      "writeAcceleratorEnabled": false
    }
  },
  "tags": {},
  "timeCreated": "2025-09-16T12:21:38.6381969+00:00",
  "type": "Microsoft.Compute/virtualMachines",
  "vmId": "<vm_id>"
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
```bash
azureuser@SampleVM-TP2:~$ az keyvault list --query "[].name" -o tsv
kv-tp2-j0w9
```
```bash
azureuser@SampleVM-TP2:~$ az keyvault secret list --vault-name "kv-tp2-j0w9" --query "[].name" -o tsv
tp2-super-secret-j0w9
```
```bash
azureuser@SampleVM-TP2:~$ az keyvault secret show --name "tp2-super-secret-j0w9" --vault-name "kv-tp2-j0w9"
{
  "attributes": {
    "created": "2025-09-16T12:24:02+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoverableDays": 7,
    "recoveryLevel": "CustomizedRecoverable+Purgeable",
    "updated": "2025-09-16T12:24:02+00:00"
  },
  "contentType": "",
  "id": "https://kv-tp2-j0w9.vault.azure.net/secrets/tp2-super-secret-j0w9/5247fd9548124b5bb20c88ee38a23a2d",
  "kid": null,
  "managed": null,
  "name": "tp2-super-secret-j0w9",
  "tags": {},
  "value": "Yo*_u(ecPzgqgS1)%w:pdx6<VPj6]BaV"
}
```

```bash
make get-secret-azure
```