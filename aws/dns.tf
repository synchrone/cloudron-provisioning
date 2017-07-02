resource "aws_route53_delegation_set" "cloudron_zone_reusable_delegation_set" {
  reference_name = "${var.domain}"
}
resource "aws_route53_zone" "cloudron_zone" {
  name = "${var.domain}"
  delegation_set_id = "${aws_route53_delegation_set.cloudron_zone_reusable_delegation_set.id}"
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
