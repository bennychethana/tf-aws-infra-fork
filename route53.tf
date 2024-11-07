# Route53 Configuration
data "aws_route53_zone" "selected" {
  name = var.domain_name
}

# Create A record
resource "aws_route53_record" "webapp" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"
  # ttl     = "300" # Commented out as we are using ALB
  # records = [aws_instance.webapp_instance.public_ip] # Commented out as we are using ALB
  alias {
    name                   = aws_lb.webapp_lb.dns_name
    zone_id                = aws_lb.webapp_lb.zone_id
    evaluate_target_health = true
  }
}