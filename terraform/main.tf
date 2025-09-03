# ===========================
# PROVIDER GCP
# ===========================
provider "google" {
  project = "cluster-kubernetes-wordpress"        # Remplace par ton ID de projet GCP
  region  = "us-central1"           # Région du cluster
  zone    = "us-central1-a"         # Zone pour les VM
  credentials = file("~/terraform-key.json")
}

# ===========================
# RESEAU VPC
# ===========================
resource "google_compute_network" "k8s_network" {
  name                    = "k8s-network"
  auto_create_subnetworks = true  # GCP crée automatiquement un subnet
}

# ===========================
# FIREWALL pour SSH et Kubernetes
# ===========================
resource "google_compute_firewall" "k8s_fw" {
  name    = "k8s-firewall"
  network = google_compute_network.k8s_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "6443", "30000-32767"] # SSH + API Kubernetes + NodePorts
  }

  source_ranges = ["0.0.0.0/0"]
}

# Génération de la clé RSA pour Ansible
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Sauvegarder la clé privée localement pour Ansible
resource "local_file" "ansible_private_key" {
  content  = tls_private_key.ansible_key.private_key_pem
  # filename = "${path.module}/id_rsa"
  filename = "${path.module}/id_rsa_ansible"
  file_permission = "0600"
}


# ===========================
# VM Ansible
# ===========================
resource "google_compute_instance" "ansible" {
  name         = "ansible"
  machine_type = "e2-small"  # 1 vCPU, 2GB RAM
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.k8s_network.name
    access_config {}  # Attribution IP publique
  }
   
  metadata = {
    # ssh-keys = "ansible:${tls_private_key.ansible_key.public_key_openssh}"
    ssh-keys = "ansible:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["ansible"]
}

# ===========================
# CLUSTER GKE
# ===========================
resource "google_container_cluster" "wordpress-cluster" {
  name       = "wordpress-cluster"
  location   = "us-central1-a"  # zone unique
  networking_mode = "VPC_NATIVE"

  deletion_protection = false

  # Crée directement un node pool minimal intégré
  initial_node_count = 1

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 20
    disk_type    = "pd-standard"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# ===========================
# NODE POOL GKE
# ===========================
# # le vrai
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  cluster    = google_container_cluster.wordpress-cluster.name
  location   = google_container_cluster.wordpress-cluster.location
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 20
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# ===========================
# PERSISTENT DISK pour PV (optionnel)
# ===========================
resource "google_compute_disk" "mysql_pv" {
  name  = "mysql-pv-disk"
  type  = "pd-standard"
  zone  = "us-central1-a"
  size  = 10  # 50 GB
}