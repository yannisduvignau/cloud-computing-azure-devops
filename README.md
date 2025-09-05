# M1 Cloud Computing - Azure DevOps
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

### Encryption algorithm for generating an SSH key pair
#### Why 'vous n'utiliserez PAS RSA'
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

#### Recommendation of another encryption algorithm
Un bon algorithme cryptographique repose sur plusieurs fondations essentielles : la sécurité, la performance, et la capacité à évoluer (c’est-à-dire la maturité/crypto-agilité assurée par une documentation active et une adoption pérenne) — comme le recommande le NIST. Source : [url](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.39.2pd.pdf)
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

## TP2 : 'Aller plus loin avec Azure'