
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare" # 👈 반드시 이 소스 주소여야 합니다.
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
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
  config_src = "cloudflare" 
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cat_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.id

  config {
    ingress_rule {
      hostname = var.domain
      service  = "http://localhost:80" # 앱 서비스가 LoadBalancer/NodePort 포트 80인 경우
    }
    
    ingress_rule {
      hostname = "prom.${var.domain}"
      service  = "http://localhost:30090" # 👈 9090에서 30090으로 변경
    }

    ingress_rule {
      hostname = "alerts.${var.domain}"
      service  = "http://localhost:30093" # 👈 9093에서 30093으로 변경
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

# DNS 레코드들
resource "cloudflare_record" "tunnel_record" {
  zone_id = var.cloudflare_zone_id
  name    = "@" # 루트 도메인
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "prom" {
  zone_id = var.cloudflare_zone_id
  name    = "prom"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "alerts" {
  zone_id = var.cloudflare_zone_id
  name    = "alerts"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = var.domain
  type    = "CNAME"
  proxied = true
}