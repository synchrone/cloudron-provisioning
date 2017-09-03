resource "aws_route53_zone" "cloudron_zone" {
  tags = {Project = "cloudron"}
  name = "${var.domain}."
  delegation_set_id = "${var.r53_delegation_set}"
}
resource "aws_route53_record" "ns" {
  zone_id = "${aws_route53_zone.cloudron_zone.zone_id}"
  name    = "${var.domain}"
  type    = "NS"
  ttl     = "30" #default is 24 hours, which is terrible for debugging delegated subdomains
  records = [
    "${aws_route53_zone.cloudron_zone.name_servers.0}",
    "${aws_route53_zone.cloudron_zone.name_servers.1}",
    "${aws_route53_zone.cloudron_zone.name_servers.2}",
    "${aws_route53_zone.cloudron_zone.name_servers.3}"
  ]
}
resource "aws_route53_record" "apex" {
  zone_id = "${aws_route53_zone.cloudron_zone.zone_id}"
  name    = "${var.domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.cloudron.public_ip}"]
}
resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.cloudron_zone.zone_id}"
  name    = "*.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${var.domain}"]
}
