output "server_ip" {
  value = google_compute_instance.web_server.network_interface.0.access_config.0.nat_ip
}

output "domain_name" {
  value = "bucheongoyangijanggun.com"
}
