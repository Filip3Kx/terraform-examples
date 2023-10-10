provider "google" {
    credentials = file("key.json")
    project     = var.gcp_info.project
    region      = "europe-west1"
    zone        = "europe-west1-b"
}

# variables:
# subnetwork_region
# zone
# project
# node_count
# machine_type
# name_prefix

module "gke-cluster" {
    source = "./modules/gke"
    subnetwork_region = "europe-west1"
    zone = "europe-west1-b"
    project = "todo"
    node_count = "3"
    machine_type = "e2-small"
    name_prefix = "dev"
}