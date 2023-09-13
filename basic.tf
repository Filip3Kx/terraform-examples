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
resource "google_compute_instance" "vm_world" {
    name         = "vm-world"
    machine_type = "f1-micro"
    zone         = "europe-west1-b"

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    network_interface {
        network = "default"
    }

    metadata_startup_script = "echo 'Hello World' > /tmp/message.txt"
}
