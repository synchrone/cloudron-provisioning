resource "google_dns_managed_zone" "cloudron_zone" {
  name = "${replace(var.domain, ".","-")}"
  dns_name = "${var.domain}."
}

//resource "google_dns_record_set" "ns" {
//  managed_zone = "${google_dns_managed_zone.cloudron_zone.name}"
//  name    = "${var.domain}."
//  type    = "NS"
//  ttl     = "30" #default is 24 hours, which is terrible for debugging delegated subdomains
//  rrdatas = [
//    "${google_dns_managed_zone.cloudron_zone.name_servers.0}",
//    "${google_dns_managed_zone.cloudron_zone.name_servers.1}",
//    "${google_dns_managed_zone.cloudron_zone.name_servers.2}",
//    "${google_dns_managed_zone.cloudron_zone.name_servers.3}"
//  ]
//}

resource "google_dns_record_set" "apex" {
  managed_zone = "${google_dns_managed_zone.cloudron_zone.name}"
  name    = "${var.domain}."
  type    = "A"
  ttl     = "300"
  rrdatas = ["${google_compute_instance.cloudron.network_interface.0.access_config.0.assigned_nat_ip}"]
}
resource "google_dns_record_set" "my" { //cloudron normally creates is by itself, but not immediately
  managed_zone = "${google_dns_managed_zone.cloudron_zone.name}"
  name    = "my.${var.domain}."
  type    = "A"
  ttl     = "300"
  rrdatas = ["${google_compute_instance.cloudron.network_interface.0.access_config.0.assigned_nat_ip}"]
}
resource "google_dns_record_set" "www" {
  managed_zone = "${google_dns_managed_zone.cloudron_zone.name}"
  name    = "*.${var.domain}."
  type    = "CNAME"
  ttl     = "300"
  rrdatas = ["${var.domain}."]
}
