output "server_ip" {
  value = module.compute.server_ip
}

output "tunnel_token" {
  value     = module.cloudflare.tunnel_token
  sensitive = true
}

output "domain_name" {
  value = "bucheongoyangijanggun.com"
}
