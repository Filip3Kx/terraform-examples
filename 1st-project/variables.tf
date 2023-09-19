variable "gcp_info" {
  type = map
  default = {
    project = "caramel-compass-393820"
    region = "europe-west1"
    zone = "europe-west1-b"

  }
}
variable "instance_info" {
  type = map
  default = {
    machine_type = "n1-standard-1"
    image_family = "debian-11"
    image_project = "debian-cloud"
  }
}
variable "instance_tags" {
  type = list(string)
  default = ["allow-ssh", "allow-http", "terraform-tp"]
  
}
variable "autoscaler_info" {
  type = map
  default = {
    max_replicas = 5
    min_replicas = 2
    cooldown_period = 60
    cpu_utilization_target = 0.5
  }  
}

variable "lb_tags" {
  type = list(string)
  default = ["terraform-tp"]
}
variable "lb_port" {
    type = number
    default = 80
}