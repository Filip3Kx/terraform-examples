variable "gcp_info" {
  type = map
  default = {
    project = "using-terraf-159-09806784"
    region = "europe-west1"
    zone = "europe-west1-b"

  }
}
variable "instance_info" {
  type = map
  default = {
    machine_type = "n1-standard-1"
    tags = ["foo", "bar", "allow-lb-service"]
    image_family = "centos-7"
    image_project = "centos-cloud"
    metadata_foo = "bar"
  }
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

variable "lb_info" {
  type = map
  default = {
    source = "GoogleCloudPlatform/lb/google"
    version="2.2.0"
    target_tags=["terraform-tp"]
    service_port = 80
  }
}