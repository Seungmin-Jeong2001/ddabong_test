terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
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
  
  # [핵심 수정] 아래 config_src 속성을 반드시 "cloudflare"로 지정해야 
  # 하단에 작성한 tunnel_config 리소스(원격 라우팅)가 정상적으로 반영됩니다.
  config_src = "cloudflare" 
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cat_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.id

  config {
    ingress_rule {
      hostname = var.domain
      service  = "http://localhost:80"
    }
    ingress_rule {
      hostname = "www.${var.domain}"
      service  = "http://localhost:80"
    }
    # Catch-all 규칙 (아주 잘 작성하셨습니다)
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "tunnel_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain
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