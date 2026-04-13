output "server_ip" {
  value = google_compute_instance.web_server.network_interface.0.access_config.0.nat_ip
}

output "tunnel_token" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.cat_tunnel.tunnel_token
  sensitive = true
}

output "domain_name" {
  value = "bucheongoyangijanggun.com"
}
