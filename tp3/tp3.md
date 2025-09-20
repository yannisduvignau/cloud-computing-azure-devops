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
 - Installation et Préparation de la Base de Données : OpenNebula requiert une base de données pour fonctionner. Nous allons installer et configurer MySQL.
```bash
    sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm
    sudo dnf install -y mysql-community-server
```

 - Démarrer et Sécuriser MySQL
```bash
    sudo systemctl enable --now mysqld

    TEMP_PASS=$(sudo grep 'temporary password' /var/log/mysqld.log | sed 's/.*root@localhost: //')
    echo "Mot de passe temporaire de root : ${TEMP_PASS}"

    mysql -u root -p
```
```sql
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'votre_mot_de_passe_root_solide';
    CREATE USER 'oneadmin' IDENTIFIED BY 'mot_de_passe_oneadmin_solide_pour_db';
    CREATE DATABASE opennebula;
    GRANT ALL PRIVILEGES ON opennebula.* TO 'oneadmin';
    SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXIT;
```

 - Installation des Dépôts et Paquets OpenNebula

Sur frontend.one uniquement :
```bash
    sudo dnf install -y https://downloads.opennebula.io/repo/opennebula-6.8.0-1.el9.x86_64.rpm
    sudo dnf install -y opennebula-server opennebula-sunstone
```
opennebula-server : Le coeur du service (démon oned)
opennebula-sunstone : L'interface web

 - Connecter OpenNebula à la Base de Données
Éditez le fichier /etc/one/oned.conf et remplacez la section DB par celle-ci, en utilisant le mot de passe que vous avez créé pour l'utilisateur oneadmin de la base de données : 
```conf
    DB = [ backend = "mysql",
       server  = "localhost",
       port    = 3306,
       user    = "oneadmin",
       passwd  = "mot_de_passe_oneadmin_solide_pour_db",
       db_name = "opennebula" ]
```

 - Créer l'Utilisateur pour l'Interface Web
Plutôt que de simplement lire un fichier généré, nous allons définir explicitement les identifiants de l'administrateur de l'interface web.
```bash
    sudo su - oneadmin -c "echo 'oneadmin:mot_de_passe_solide_pour_webui' > /var/lib/one/.one/one_auth"
```

 - Configuration du Pare-feu (firewalld) : Ouvrir les ports pour l'interface web Sunstone, l'API et le monitoring
```bash
    sudo firewall-cmd --add-port=9869/tcp --permanent

    sudo firewall-cmd --add-port=2633/tcp --permanent
    sudo firewall-cmd --add-port=4124/tcp --permanent
    sudo firewall-cmd --add-port=4124/udp --permanent

    sudo firewall-cmd --reload
```

 - Démarrage et Activation des Services (Activation au redémarrage de la machine)
```bash
    sudo systemctl enable --now opennebula.service
    sudo systemctl enable --now opennebula-sunstone.service
```


8. Configuration du Nœud KVM (kvm1.one)
Ce nœud fournira la puissance de calcul pour faire tourner nos VMs. Le frontend le pilotera via SSH.
 - Installation des Paquets de Virtualisation et du Nœud OpenNebula

Sur kvm1.one uniquement :
```bash
    sudo dnf install -y https://downloads.opennebula.io/repo/opennebula-6.8.0-1.el9.x86_64.rpm

    sudo dnf install -y epel-release

    sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm

    sudo dnf install -y opennebula-node-kvm mysql-community-server genisoimage

    sudo systemctl start libvirtd.service
    sudo systemctl enable libvirtd.service
```
Installation des paquets de virtualisation et de l'agent OpenNebula
opennebula-node-kvm : C'est le paquet clé. Il installe l'agent OpenNebula ainsi que qemu-kvm et libvirt, le nécessaire pour l'hyperviseur.
mysql-community-server : Libs requises par l'agent.
genisoimage : Outil utilisé pour créer les images de contexte des VMs.

 - Configuration Système et Sécurité
Ouverture du Pare-feu : On configure firewalld sur kvm1.one pour n'autoriser que les communications strictement nécessaires.
```bash
    sudo firewall-cmd --add-port=22/tcp --permanent
    sudo firewall-cmd --add-port=8472/udp --permanent
    sudo firewall-cmd --reload
```

 - Configuration de l'accès SSH (Très Important)
Passez sur frontend.one et devenez l'utilisateur oneadmin : 
```bash
    ssh user@frontend.one
```
```bash
    [user@frontend ~]$ sudo su - oneadmin
    [oneadmin@frontend ~]$ ssh-copy-id oneadmin@kvm1.one
```
Le système vous demandera une seule et unique fois le mot de passe de l'utilisateur oneadmin sur kvm1.one pour autoriser la copie.

Pré-approuvez l'empreinte de l'hôte pour éviter la demande de confirmation de connexion.
```bash
    [oneadmin@frontend ~]$ ssh-keyscan kvm1.one >> ~/.ssh/known_hosts
```

Vérification finale. La commande suivante doit maintenant s'exécuter instantanément et retourner le nom d'hôte de votre nœud KVM, sans aucune question.
```bash
    [oneadmin@frontend ~]$ ssh oneadmin@kvm1.one hostname
```

9. Configuration du Réseau Virtuel VXLAN
 - Création du Réseau Virtuel (via WebUI)
```bash
    Name : Donnez un nom explicite, par exemple vxlan-private-net.
    Network Mode : Sélectionnez vxlan.
    Physical device : Indiquez le nom de l'interface réseau de votre hyperviseur qui a une IP statique (ex: enp0s3).
    Bridge : Nommez le bridge qui sera créé sur l'hôte. Utilisons vxlan_bridge pour la cohérence.
    First IPv4 address : 10.220.220.100 (une plage privée est recommandée).
    Size : 50 (cela créera un pool de 50 adresses IP disponibles pour les VMs).
    NETWORK_ADDRESS : 10.220.220.0
    NETWORK_MASK : 255.255.255.0
```

 - Préparation du Bridge Réseau sur l'Hôte (kvm1.one)
On crée un réseau virtuel de niveau 2 par-dessus notre réseau physique. Ce réseau sera utilisé exclusivement par les VMs pour communiquer entre elles, de manière isolée.
```bash
    sudo nmcli con add type bridge con-name vxlan_bridge ifname vxlan_bridge
    sudo nmcli con mod vxlan_bridge ipv4.addresses 10.220.220.201/24 ipv4.method manual
    sudo nmcli con up vxlan_bridge
    sudo firewall-cmd --zone=public --add-interface=vxlan_bridge --permanent
    sudo firewall-cmd --zone=public --add-masquerade --permanent

    sudo firewall-cmd --reload
```