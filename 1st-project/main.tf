provider "google" {
    credentials = file("key.json")
    project     = var.gcp_info.project
    region      = var.gcp_info.region
    zone        = var.gcp_info.zone
}



data "google_compute_image" "debian" {
  family  = var.instance_info.image_family
  project = var.instance_info.image_project
}



resource "google_compute_network" "terraform-network" {
    name = "terraform-network"
}



resource "google_compute_firewall" "ssh-rule" {
  name = "terraform-ssh"
  network = google_compute_network.terraform-network.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "http-rule" {
  name = "terraform-http"
  network = google_compute_network.terraform-network.name
  allow {
    protocol = "tcp"
    ports = ["80"]
  }
  target_tags = ["allow-http"]
  source_ranges = ["0.0.0.0/0"]
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
    tags = var.instance_tags
    disk {
      source_image = data.google_compute_image.debian.self_link
    }
    network_interface {
      network = google_compute_network.terraform-network.name
      access_config {}
    }
    metadata_startup_script = <<EOF
        sudo apt update
        sudo apt install -y nginx
        echo "hello world 1" | sudo tee /var/www/html/index.html
        sudo systemctl restart nginx
    EOF
}



resource "google_compute_instance_group_manager" "terraform-gm" {
    name = "terraform-gm"
    zone = var.gcp_info.zone
    project = var.gcp_info.project
    version {
      instance_template = google_compute_instance_template.terraform-instance-template.self_link
      name = "primary"
    }
    target_pools = [module.lb.target_pool]
    base_instance_name = "terraform"
}


#Load balancer
module "lb" {
  source = "GoogleCloudPlatform/lb/google"
  version = "2.2.0"
  region = var.gcp_info.region
  name = "terraform-lb"
  service_port = var.lb_port
  target_tags = var.lb_tags
  network = google_compute_network.terraform-network.name
}