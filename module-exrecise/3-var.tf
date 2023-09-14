variable "bucket_info" {
    type = map
    default = {
        name = "tf-state-bucket115"
        prefix = "terraform/state"
    }
}


variable "google_info" {
  type = map
  default = {
    project = "caramel-compass-393820"
    region = "europe-west1-b"
    sa_key = "key.json"
  }
}


variable "vm1_info" {
    type = map
    default = {
        name = "http1-vm"
        size = "f1-micro"
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        network = "http-network"
    }
}


variable "vm2_info" {
    type = map
    default = {
        name = "http2-vm"
        size = "f1-micro"
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        network = "http-network"
    }
}
