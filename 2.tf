# $Env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\fkubawsx\OneDrive - Intel Corporation\terraform-examples\key.json"
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
resource "google_compute_instance" "vm_world" {
    name         = var.vm_info.name
    machine_type = var.vm_info.size
    zone         = var.google_info.region

    boot_disk {
        initialize_params {
            image = var.vm_info.image
        }
    }

    network_interface {
        network = var.vm_info.network
    }

    metadata_startup_script = <<-EOF
        #!/bin/bash
        #DOCKER INSTALL
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose docker-buildx-plugin docker-compose-plugin -y
    EOF
}

resource "google_app_engine_application" "app" {
  project     =  var.google_info.project
  location_id =  var.google_info.region
}
