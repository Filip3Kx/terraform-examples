provider "google" {
    credentials = file("key.json")
    project     = "using-terraf-156-6d3a78c0"
    region      = "europe-west1"
    zone        = "europe-west1-b"
}
resource "google_compute_network" "vpc-network" {
    name = "terraform-network"
}
resource "google_compute_subnetwork" "public-subnetwork" {
    name = "terraform-subnetwork"
    ip_cidr_range = "10.2.0.0/16"
    region = "europe-west1"
    network = google_compute_network.vpc-network.name
  
}