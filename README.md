#  Déploiement automatisé de WordPress & MySQL sur Kubernetes avec Terraform et Ansible

##  Objectif

Ce projet a pour but d’automatiser le déploiement d’une plateforme **WordPress** avec une base de données **MySQL** sur un cluster **Kubernetes** hébergé dans **Google Cloud Platform (GCP)**.  
L’infrastructure est provisionnée avec **Terraform** et la configuration applicative est gérée avec **Ansible**.

---

##  Architecture déployée

```mermaid
graph TD
    A[Terraform] -->|Provisionne| B[GCP]
    B --> C[GKE Cluster]
    B --> D[VM Ansible]
    C --> E[Worker 1: Pods WordPress]
    C --> F[Worker 2: Pods MySQL + NFS]
    D -->|Playbooks Ansible| C


---

> **English version below**

---


# Automated Deployment of WordPress & MySQL on Kubernetes with Terraform and Ansible

## Objective

This project aims to automate the deployment of a **WordPress** platform with a **MySQL** database on a **Kubernetes** cluster hosted in **Google Cloud Platform (GCP)**.  
The infrastructure is provisioned with **Terraform**, and the application configuration is managed using **Ansible**.

