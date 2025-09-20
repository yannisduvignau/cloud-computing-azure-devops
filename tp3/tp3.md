## TP3 : Self-hosted private cloud platform

1. Création et Installation de la VM de Base
 - Création de la VM (Rocky Linux 9) avec 2 Go de RAM (3 ou 4 Go sont plus confortables) et 1 CPU.
 - Réseau > Adaptateur 1 : NAT (Accès par traduction d'adresse) pour qu'il puisse accéder à Internet et télécharger les mises à jour. Réseau > Adaptateur 2 : Activez-le et choisissez Réseau privé d'hôte (Host-only Network) nommé CloudComputingNetwork.

2. Préparation du Système pour le Clonage
 - Mise à jour complète pour que le modèle soit à jour : 
```bash 
  dnf update -y 
```

 - Installation d'outils utiles : 
```bash
  dnf install -y wget curl git vim net-tools 
```

 - Désactivation de SELinux
```bash
  sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
  setenforce 0
```

 - Nettoyer le cache DNF : 
```bash 
  dnf clean all 
```

 - Supprimer les identifiants machine uniques : 
```bash 
  truncate -s 0 /etc/machine-id
  rm -f /var/lib/systemd/random-seed
```

 - Nettoyer les logs et l'historique : 
```bash 
  logrotate -f /etc/logrotate.conf
  rm -f /var/log/*-???????? /var/log/*.gz
  rm -f /var/log/dmesg.old
  cat /dev/null > /var/log/audit/audit.log
  cat /dev/null > /var/log/wtmp
  cat /dev/null > /var/log/lastlog
  cat /dev/null > /var/log/grubby

  history -c && history -w
```

 - Arrêt de la VM : 
```bash 
  poweroff
```

3. Clonage de la VM

4. Activer la Virtualisation Imbriquée (Nested Virtualization)
 - bcdedit /set hypervisorlaunchtype off
Allez dans Configuration > Système > Processeur.
Cochez la case "Activer Nested VT-x/AMD-V".

5. Configuration Élémentaire des VMs
 - Configurer les Adresses IP Statiques : 
    - nmcli connection show 
    - 10.3.1.10/24 (frontend.one)
```bash
    sudo nmcli con mod enp0s3 ipv4.addresses 10.3.1.10/24
    sudo nmcli con mod enp0s3 ipv4.gateway 10.3.1.1
    sudo nmcli con mod enp0s3 ipv4.dns "8.8.8.8,1.1.1.1"
    sudo nmcli con mod enp0s3 ipv4.method manual
    sudo nmcli con up enp0s3
    ip addr show enp0s3
```
    - 10.3.1.11/24 (kvm1.one)
```bash
    sudo nmcli con mod enp0s3 ipv4.addresses 10.3.1.11/24
    sudo nmcli con mod enp0s3 ipv4.gateway 10.3.1.1
    sudo nmcli con mod enp0s3 ipv4.dns "8.8.8.8,1.1.1.1"
    sudo nmcli con mod enp0s3 ipv4.method manual
    sudo nmcli con up enp0s3
    ip addr show enp0s3
``` 
    - 10.3.1.12/24 (kvm2.one)
```bash
    sudo nmcli con mod enp0s3 ipv4.addresses 10.3.1.12/24
    sudo nmcli con mod enp0s3 ipv4.gateway 10.3.1.1
    sudo nmcli con mod enp0s3 ipv4.dns "8.8.8.8,1.1.1.1"
    sudo nmcli con mod enp0s3 ipv4.method manual
    sudo nmcli con up enp0s3
    ip addr show enp0s3
```
 - sudo systemctl restart NetworkManager

Pour que chaque machine soit correctement identifiée sur le réseau et par les services OpenNebula, on leur assigne un nom d'hôte unique.
 - Définir le Nom d'Hôte (Hostname) :
    - sudo hostnamectl set-hostname frontend.one (sur frontend.one)
    - sudo hostnamectl set-hostname kvm1.one (sur kvm1.one)
    - sudo hostnamectl set-hostname kvm2.one (sur kvm2.one)

Le fichier /etc/hosts permet de faire correspondre des noms d'hôtes à des adresses IP sans avoir besoin d'un serveur DNS. C'est une pratique courante et robuste pour les petits clusters.
 - Ajout dans le Fichier /etc/hosts : sudo vim /etc/hosts (sur les 3 VMs)
    - \# === Configuration du Cluster OpenNebula ===
    - 10.3.1.10   frontend.one
    - 10.3.1.11   kvm1.one
    - 10.3.1.12   kvm2.one

6. Vérification pour le Compte-Rendu
 - Connectez-vous à frontend.one. 
    - Lancez un ping vers kvm1.one : ping -c 4 kvm1.one
```bash
    PING kvm1.one (10.3.1.11) 56(84) bytes of data.
    64 bytes from kvm1.one (10.3.1.11): icmp_seq=1 ttl=64 time=0.512 ms
    64 bytes from kvm1.one (10.3.1.11): icmp_seq=2 ttl=64 time=0.435 ms
    64 bytes from kvm1.one (10.3.1.11): icmp_seq=3 ttl=64 time=0.487 ms
    64 bytes from kvm1.one (10.3.1.11): icmp_seq=4 ttl=64 time=0.413 ms

    --- kvm1.one ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3075ms
    rtt min/avg/max/mdev = 0.413/0.461/0.512/0.039 ms
```
    - Lancez un ping vers kvm2.one : ping -c 4 kvm2.one
```bash
    PING kvm2.one (10.3.1.12) 56(84) bytes of data.
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=1 ttl=64 time=0.530 ms
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=2 ttl=64 time=0.491 ms
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=3 ttl=64 time=0.511 ms
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=4 ttl=64 time=0.456 ms

    --- kvm2.one ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3082ms
    rtt min/avg/max/mdev = 0.456/0.497/0.530/0.028 ms
```

7. Configuration du Frontend (frontend.one)
Le frontend est le cerveau de notre infrastructure. Il héberge les services principaux d'OpenNebula, la base de données et l'interface web (Sunstone).
 - Installation des Dépôts et Paquets OpenNebula

Sur frontend.one uniquement :
```bash
    sudo dnf install -y https://downloads.opennebula.io/repo/opennebula-6.8.0-1.el9.x86_64.rpm
    sudo dnf install -y opennebula-server opennebula-sunstone
```
opennebula-server : Le coeur du service (démon oned)
opennebula-sunstone : L'interface web

 - Configuration du Pare-feu (firewalld) : Ouvrir le port 9869/tcp pour Sunstone
```bash
    sudo firewall-cmd --add-port=9869/tcp --permanent
    sudo firewall-cmd --reload
```

 - Démarrage et Activation des Services (Activation au redémarrage de la machine)
```bash
    sudo systemctl start opennebula.service
    sudo systemctl start opennebula-sunstone.service

    sudo systemctl enable opennebula.service
    sudo systemctl enable opennebula-sunstone.service
```

OpenNebula crée un utilisateur système oneadmin pour gérer l'ensemble de l'infrastructure. Le mot de passe initial pour l'interface web est stocké dans un fichier.
 - Accès Initial et Sécurité : Récupérer le mot de passe pour l'utilisateur "oneadmin"
```bash
    cat /var/lib/one/.one/one_auth
```

8. Configuration du Nœud KVM (kvm1.one)
Ce nœud fournira la puissance de calcul pour faire tourner nos VMs. Le frontend le pilotera via SSH.
 - Installation des Paquets de Virtualisation et du Nœud OpenNebula

Sur kvm1.one uniquement :
```bash
    sudo dnf install -y https://downloads.opennebula.io/repo/opennebula-6.8.0-1.el9.x86_64.rpm

    sudo dnf install -y qemu-kvm libvirt-daemon-kvm opennebula-node-kvm

    sudo systemctl start libvirtd.service
    sudo systemctl enable libvirtd.service
```
Installation des paquets de virtualisation et de l'agent OpenNebula
qemu-kvm & libvirt-daemon-kvm : Le nécessaire pour l'hyperviseur
opennebula-node-kvm : L'agent qui permet au frontend de piloter ce noeud

 - Configuration de l'accès SSH (Très Important)
Sur frontend.one, copiez la clé publique de l'utilisateur oneadmin:
```bash
sudo su - oneadmin -c "cat ~/.ssh/id_rsa.pub"
```

Le frontend doit pouvoir se connecter en SSH au nœud KVM en tant que oneadmin sans mot de passe, en utilisant une authentification par clé.
Sur kvm1.one, ajoutez cette clé au fichier des clés autorisées pour oneadmin :
```bash
    sudo install -d -o oneadmin -g oneadmin -m 700 /var/lib/one/.ssh
    
    sudo su - oneadmin -c "echo 'ssh-rsa <ssh_key> oneadmin@frontend.one' >> ~/.ssh/authorized_keys"

    sudo chmod 600 /var/lib/one/.ssh/authorized_keys
```

Sur frontend.one, testez la connexion :
```bash
    sudo su - oneadmin -c "ssh kvm1.one hostname"
```

9. Configuration du Réseau VXLAN (kvm1.one)
On crée un réseau virtuel de niveau 2 par-dessus notre réseau physique. Ce réseau sera utilisé exclusivement par les VMs pour communiquer entre elles, de manière isolée.
 - Créer le bridge Linux qui servira de switch virtuel pour les VMs
```bash
    sudo nmcli con add type bridge con-name br0 ifname br0
    sudo nmcli con mod br0 ipv4.addresses 10.220.220.201/24 ipv4.method manual
```

 - Créer l'interface VXLAN
```bash
    sudo nmcli con add type vxlan con-name vxlan10 ifname vxlan10 id 10 remote 10.3.1.12 local 10.3.1.11 dev enp0s3 dstport 4789
```
ID (VNI) 10 : L'identifiant du réseau virtuel.
remote 10.3.1.12 : On prépare déjà la communication avec le futur kvm2.one
destination-port 4789 : Le port standard pour VXLAN

 - Attacher l'interface VXLAN au bridge
```bash
    sudo nmcli con add type bridge-slave con-name br0-port-vxlan10 ifname vxlan10 master br0
```

 - Activer les nouvelles connexions
```bash
    sudo nmcli con up br0
    sudo nmcli con up br0-port-vxlan10
```