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
    # 1. 메인 앱 (cat-web)
    ingress_rule {
      hostname = var.domain
      service  = "http://localhost:80"
    }
    
    # 2. Prometheus (추가)
    ingress_rule {
      hostname = "prom.${var.domain}"
      service  = "http://localhost:9090"
    }

    # 3. Alertmanager (추가)
    ingress_rule {
      hostname = "alerts.${var.domain}"
      service  = "http://localhost:9093"
    }

    # 4. www 서브도메인
    ingress_rule {
      hostname = "www.${var.domain}"
      service  = "http://localhost:80"
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