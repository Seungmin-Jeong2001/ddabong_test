# 기존 SSH 허용 규칙은 유지
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

resource "google_compute_firewall" "allow_services" {
  name    = "allow-web-and-monitor"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "9090", "9093"] # 웹 서비스, 프로메테우스, 얼럿매니저
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"] # module.compute에서 인스턴스에 부여한 태그와 일치해야 함
}