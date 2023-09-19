provider "google" {
    credentials = file("key.json")
    project     = var.gcp_info.project
    region      = var.gcp_info.region
    zone        = var.gcp_info.zone
}


data "google_compute_image" "centos_7" {
  family  = var.instance_info.image_family
  project = var.instance_info.image_project
}


resource "google_compute_network" "terraform-network" {
    name = "terraform-network"
}


resource "google_compute_autoscaler" "terraform-autoscaler" {
    name = "terraform-autoscaler"
    zone = var.gcp_info.zone
    target = google_compute_instance_group_manager.terraform-gm.name
    autoscaling_policy {
      max_replicas = var.autoscaler_info.max_replicas
      min_replicas = var.autoscaler_info.min_replicas
      cooldown_period = var.autoscaler_info.cooldown_period
      cpu_utilization {
        target = var.autoscaler_info.cpu_utilization_target
      }
    }
}


resource "google_compute_instance_template" "terraform-instance-template" {
    name = "terraform-instance-template"
    machine_type = var.instance_info.machine_type
    can_ip_forward = false
    project = var.gcp_info.project
    tags = var.instance_info.tags
    disk {
      source_image = data.google_compute_image.centos_7.self_link
    }
    network_interface {
      network = google_compute_network.terraform-network.name
      access_config {}
    }
    metadata = {
        foo = var.instance_info.metadata_foo
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
  project = var.gcp_info.project
  region = var.gcp_info.region
}


resource "google_compute_instance_group_manager" "terraform-gm" {
    name = "terraform-gm"
    zone = var.gcp_info.zone
    project = var.gcp_info.project
    version {
      instance_template = google_compute_instance_template.terraform-instance-template.self_link
      name = "primary"
    }
    target_pools = [google_compute_target_pool.terraform-tp.self_link]
    base_instance_name = "terraform"
}


module "lb" {
  source = var.lb_info.source
  version = var.lb_info.version
  region = var.gcp_info.region
  name = "terraform-lb"
  service_port = var.lb_info.service_port
  target_tags = var.lb_info.target_tags
  network = google_compute_network.terraform-network.name
}