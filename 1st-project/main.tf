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

resource "google_service_account" "http-sa" {
  account_id   = "http-servers-sa"
  display_name = "HTTP Servers Service Account"
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
      email = google_service_account.http-sa.email
      scopes = [cloud-platform]
    }
    metadata_startup_script = <<EOF
        sudo apt update
        sudo apt install -y nginx
        echo "hello world 1" | sudo tee /var/www/html/index.html
        sudo systemctl restart nginx
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