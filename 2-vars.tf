variable "google_info" {
  type = map
  default = {
    project = "caramel-compass-393820"
    region = "europe-west1-b"
    sa_key = "key.json"
  }
}

variable "vm_info" {
    type = map
    default = {
        name = "docker_vm"
        size = "f1-micro"
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        network = "default"
    }
}
variable "bucket_info" {
    type = map
    default = {
        name = "tf-state-bucket115"
        prefix = "terraform/state"
    }
}
