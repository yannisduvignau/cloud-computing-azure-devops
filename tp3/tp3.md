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
  sudo nmcli connection modify enp0s3 \
      ipv4.method "manual" \
      ipv4.addresses "10.3.1.10/24" \
      ipv4.gateway "10.3.1.1" \
      ipv4.dns "8.8.8.8"
  sudo nmcli connection up enp0s3
  ip addr show enp0s3
```
    - 10.3.1.10/24 (kvm1.one)
```bash
  sudo nmcli connection modify enp0s3 \
      ipv4.method "manual" \
      ipv4.addresses "10.3.1.11/24" \
      ipv4.gateway "10.3.1.1" \
      ipv4.dns "8.8.8.8"
  sudo nmcli connection up enp0s3
  ip addr show enp0s3
``` 
    - 10.3.1.12/24 (kvm2.one)
```bash
  sudo nmcli connection modify enp0s3 \
      ipv4.method "manual" \
      ipv4.addresses "10.3.1.12/24" \
      ipv4.gateway "10.3.1.1" \
      ipv4.dns "8.8.8.8"
  sudo nmcli connection up enp0s3
  ip addr show enp0s3
```
 - sudo systemctl restart NetworkManager
 - Définir le Nom d'Hôte (Hostname) : 
    - sudo hostnamectl set-hostname frontend.one (sur frontend.one)
    - sudo hostnamectl set-hostname kvm1.one (sur kvm1.one)
    - sudo hostnamectl set-hostname kvm2.one (sur kvm2.one)
 - Remplir le Fichier /etc/hosts : sudo nano /etc/hosts (sur les 3 VMs)
    - 10.3.1.10   frontend.one
    - 10.3.1.11   kvm1.one
    - 10.3.1.12   kvm2.one

6. Vérification pour le Compte-Rendu
 - Connectez-vous à frontend.one. 
    - Lancez un ping vers kvm1.one : ping -c 4 kvm1.one
```bash
  PING kvm1.one (10.3.1.11) 56(84) bytes of data.
  64 bytes from kvm1.one (10.3.1.11): icmp_seq=1 ttl=64 time=0.512 ms
  64 bytes from kvm1.one (10.3.1.11): icmp_seq=2 ttl=64 time=0.485 ms
  ...
  --- kvm1.one ping statistics ---
  4 packets transmitted, 4 received, 0% packet loss, time 3075ms
```
    - Lancez un ping vers kvm2.one : ping -c 4 kvm2.one
```bash
  PING kvm2.one (10.3.1.12) 56(84) bytes of data.
  64 bytes from kvm2.one (10.3.1.12): icmp_seq=1 ttl=64 time=0.620 ms
  ...
  --- kvm2.one ping statistics ---
  4 packets transmitted, 4 received, 0% packet loss, time 3080ms
```