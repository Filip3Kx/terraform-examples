resource "google_compute_network" "k8s-network" {
  name = "${var.name_prefix}-cluster-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "k8s-subnetwork" {
  name = "${var.name_prefix}-cluster-subnetwork"
  ip_cidr_range = "10.0.0.0/18"
  network = google_compute_network.k8s-network.name
  region = var.subnetwork_region
  private_ip_google_access = true
  secondary_ip_range {
    range_name = "${var.name_prefix}-cluster-pods"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name = "${var.name_prefix}-cluster-services"
    ip_cidr_range = "10.52.0.0/20"
  }
}

resource "google_compute_router" "router" {
  name    = "${var.name_prefix}-router"
  region  = var.subnetwork_region
  network = google_compute_network.k8s-network.name
}