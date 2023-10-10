resource "google_service_account" "cluster-sa" {
  account_id = "${var.name_prefix}cluster-sa"
  display_name = "Cluster Service Account"
}