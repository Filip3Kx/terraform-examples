provider "google" {
    credentials = file("key.json")
    project     = "building-fle-266-123c4e21"
    region      = "europe-west1"
    zone        = "europe-west1-b"
}

module "networking" {
  source = "./modules/networking"
  environment = "prod"
  cidr_range = "10.0.0.0/8"
  regions = ["us-central1", "us-east1", "us-east4", "us-west1"]
  subnet_size = 24
}