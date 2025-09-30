#  Déploiement automatisé d’une application e-commerce WordPress sur Google Kubernetes Engine (GKE)

##  Objectif
Ce projet a pour but d’automatiser la mise en place une application e-commerce **WordPress** avec une base de données **MySQL** sur un cluster GKE hébergé dans **Google Cloud Platform (GCP)**.  

- **Terraform** : Provisionnement de l’infrastructure (cluster Kubernetes, VM de gestion, stockage persistant, réseau).  
- **Ansible** : Déploiement et configuration automatisée des services applicatifs (WordPress, MySQL).  
- **Prometheus & Grafana** : Mise en place d’une supervision avancée pour suivre les performances et la disponibilité des services.  

---


##  Architecture déployée

```mermaid

graph TD
    A[Terraform] -->|Provisionne| B[GCP]
    B --> C[GKE Cluster]
    B --> D[Ansible]
    C --> E[Worker 1: Pods WordPress]
    C --> F[Worker 2: Pods MySQL + NFS]
    C --> G[Monitoring Stack: Prometheus & Grafana]
    D -->|Playbooks Ansible| C

