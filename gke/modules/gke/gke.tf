resource "google_container_cluster" "cluster" {
    name = "${var.name_prefix}-cluster"
    location = var.subnetwork_region
    remove_default_node_pool = true
    initial_node_count = 1

    network = google_compute_network.k8s-network.name
    subnetwork = google_compute_subnetwork.k8s-subnetwork.name

    ip_allocation_policy {
      cluster_secondary_range_name = "${var.name_prefix}-cluster-pods"
      services_secondary_range_name = "${var.name_prefix}-cluster-services"
    }
}

resource "google_container_node_pool" "cluster-node-pool" {
  name = "${var.name_prefix}-cluster-node-pool"
  location = var.subnetwork_region
  cluster = google_container_cluster.cluster.name
  node_count = var.node_count

  node_config {
    preemptible = true
    machine_type = var.machine_type
    service_account = google_service_account.cluster-sa.email
    oauth_scopes = [ 
      "https://www.googleapis.com/auth/cloud-platform" 
    ]
  }
}