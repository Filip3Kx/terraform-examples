# $Env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\fkubawsx\OneDrive - Intel Corporation\terraform-examples\key.json"
terraform {
    backend "gcs" {
        bucket  = "tf-state-bucket115"
        prefix  = "terraform/state"
    }
}
provider "google" {
    credentials = file("key.json")
    project     = "caramel-compass-393820"
    region      = "europe-west1-b"
}


resource "google_compute_firewall" "allow-http" {
  name        = "allow-http"
  network     = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_instance" "http1-vm" {
    name         = "http1-vm"
    machine_type = "f1-micro"
    zone         = "europe-west1-b"
    tags         = ["allow-http"]
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11-bullseye-v20230912"
        }
    }
    network_interface {
        network = "default"
        access_config {
        }
    }
    metadata_startup_script = <<-EOF
        sudo apt update
        sudo apt install -y nginx
        echo "hello world 1" | sudo tee /var/www/html/index.html
        sudo systemctl restart nginx
    EOF
}
