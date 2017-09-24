resource "google_compute_firewall" "cloudron_sg" {
  name    = "cloudron-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "25", "80", "443", "587", "993", "4190", "7494"]
  }
}
