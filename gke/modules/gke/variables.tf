variable "subnetwork_region" {
  description = "Region that subnet will be created in"
}
variable "zone" {
  description = "Zone of resources"
}
variable "project" {
  description = "Project Name"
}
variable "node_count" {
  description = "Amount of nodes"
  type = number
}
variable "machine_type" {
  description = "Type of nodes used in GKE"  
}

variable "name_prefix" {
  description = "prefix for all the resources to be identified"
}