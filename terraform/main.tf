terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-bucheong-cat"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "network" {
  source       = "./modules/network"
  network_name = "cat-monitor-network"
  subnet_name  = "cat-monitor-subnet"
}

module "compute" {
  source      = "./modules/compute"
  gcp_zone    = var.gcp_zone
  network_id  = module.network.network_id
  subnet_id   = module.network.subnet_id
  ssh_user    = var.ssh_user
  ssh_pub_key = var.ssh_pub_key
}

module "cloudflare" {
  source                = "./modules/cloudflare"
   providers = {
    cloudflare = cloudflare
  }
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_zone_id    = var.cloudflare_zone_id
  domain                = "bucheongoyangijanggun.com"
  server_ip             = module.compute.server_ip 
}
