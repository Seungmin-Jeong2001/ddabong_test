resource "google_compute_network" "vpc_network" {
  name = "cat-monitor-network"
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "cat-monitor-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-only"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}

resource "google_compute_instance" "web_server" {
  name         = "bucheong-cat-server"
  machine_type = "e2-small"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id

    access_config {
      // Keep ephemeral public IP for Ansible management
    }
  }

  tags = ["ssh-server"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_pub_key}"
  }
}

resource "random_password" "tunnel_secret" {
  length  = 32
  special = false
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "cat_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "bucheong-cat-tunnel"
  secret     = base64encode(random_password.tunnel_secret.result)
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cat_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.id

  config {
    ingress_rule {
      hostname = "bucheongoyangijanggun.com"
      service  = "http://localhost:80"
    }
    ingress_rule {
      hostname = "www.bucheongoyangijanggun.com"
      service  = "http://localhost:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "tunnel_record" {
  zone_id = var.cloudflare_zone_id
  name    = "bucheongoyangijanggun.com"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = "bucheongoyangijanggun.com"
  type    = "CNAME"
  proxied = true
}
