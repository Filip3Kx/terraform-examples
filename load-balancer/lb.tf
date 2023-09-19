provider "google" {
    credentials = file("key.json")
    project     = "using-terraf-159-09806784"
    region      = "europe-west1"
    zone        = "europe-west1-b"
}


data "google_compute_image" "centos_7" {
  family  = "centos-7"
  project = "centos-cloud"
}


resource "google_compute_network" "terraform-network" {
    name = "terraform-network"
}


resource "google_compute_autoscaler" "terraform-autoscaler" {
    name = "terraform-autoscaler"
    zone = "europe-west1-b"
    target = google_compute_instance_group_manager.terraform-gm.name
    autoscaling_policy {
      max_replicas = 5
      min_replicas = 2
      cooldown_period = 60
      cpu_utilization {
        target = 0.5
      }
    }
}


resource "google_compute_instance_template" "terraform-instance-template" {
    name = "terraform-instance-template"
    machine_type = "n1-standard-1"
    can_ip_forward = false
    project = "using-terraf-159-09806784"
    tags = ["foo", "bar", "allow-lb-service"]
    disk {
      source_image = data.google_compute_image.centos_7.self_link
    }
    network_interface {
      network = google_compute_network.terraform-network.name
      access_config {}
    }
    metadata = {
        foo = "bar"
    }
    service_account {
      scopes = []
    }
    metadata_startup_script = <<EOF
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


resource "google_compute_target_pool" "terraform-tp" {
  name = "terraform-tp"
  project = "using-terraf-159-09806784"
  region = "europe-west1"
}


resource "google_compute_instance_group_manager" "terraform-gm" {
    name = "terraform-gm"
    zone = "europe-west1-b"
    project = "using-terraf-159-09806784"
    version {
      instance_template = google_compute_instance_template.terraform-instance-template.self_link
      name = "primary"
    }
    target_pools = [google_compute_target_pool.terraform-tp.self_link]
    base_instance_name = "terraform"
}


module "lb" {
  source = "GoogleCloudPlatform/lb/google"
  version = "2.2.0"
  region = "europe-west1"
  name = "terraform-lb"
  service_port = 80
  target_tags = ["terraform-tp"]
  network = google_compute_network.terraform-network.name
}