terraform {
    backend "gcs" {
        bucket  = "tf-state-bucket115"
        prefix  = "terraform/state"
    }
}


provider "google" {
    credentials = file(var.google_info.sa_key)
    project     = var.google_info.project
    region      = var.google_info.region
}


resource "google_compute_network" "http-network" {
  name = "http-network"
  auto_create_subnetworks = true
}


resource "google_compute_instance" "http1-vm" {
    name         = var.vm1_info.name
    machine_type = var.vm1_info.size
    zone         = var.google_info.region
    boot_disk {
        initialize_params {
            image = var.vm1_info.image
        }
    }
    network_interface {
        network = google_compute_network.http-network.name
    }
    metadata_startup_script = <<-EOF
        sudo apt update -y
        sudo apt install -y nginx
        echo "hello world 1" | sudo tee /var/www/html/index.html
        sudo systemctl restart nginx
    EOF
}


resource "google_compute_instance" "http2-vm" {
    name         = var.vm2_info.name
    machine_type = var.vm2_info.size
    zone         = var.google_info.region
    boot_disk {
        initialize_params {
            image = var.vm2_info.image
        }
    }
    network_interface {
        network = google_compute_network.http-network.name
    }
    metadata_startup_script = <<-EOF
        sudo apt update -y
        sudo apt install -y nginx
        echo "hello world 2" | sudo tee /var/www/html/index.html
        sudo systemctl restart nginx
    EOF
}


resource "google_compute_http_health_check" "http-health-check" {
  name               = "http-health-check"
  request_path       = "/"
  port               = 80
}
