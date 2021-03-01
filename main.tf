module "network" {
  source  = "terraform-google-modules/network/google"
  version = "2.1.1"

  network_name = "my-vpc-network"
  project_id   = var.project

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = var.cidr
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    subnet-01 = []
  }
}

module "network_routes" {
  source       = "terraform-google-modules/network/google//modules/routes"
  version      = "2.1.1"
  network_name = module.network.network_name
  project_id   = var.project

  routes = [
    {
      name              = "egress-internet"
      description       = "Route through IGW to internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]
}

module "network_fabric-net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version                 = "1.1.0"
  project_id              = var.project
  network                 = module.network.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/16"]

}

resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}

provider "google" {
  project     = "terraform-course-306221"
  region      = "us-central1"
  zone        = "us-central1-c"
  credentials = "terraform-key.json"
}
