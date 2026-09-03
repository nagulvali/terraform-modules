locals {
  certificate_names = {
    for k, v in var.certificates : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  imported_certificate_names = {
    for k, v in var.imported_certificates : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  zone_name_lookups = toset([
    for k, v in var.certificates : v.zone_name
    if v.create_route53_records && v.zone_name != null
  ])

  validation_records = {
    for item in flatten([
      for cert_key, cert in aws_acm_certificate.this : [
        for dvo in cert.domain_validation_options : {
          key         = "${cert_key}/${replace(dvo.domain_name, "*.", "_")}"
          cert_key    = cert_key
          domain_name = dvo.domain_name
          name        = dvo.resource_record_name
          record      = dvo.resource_record_value
          type        = dvo.resource_record_type
          create      = var.certificates[cert_key].create_route53_records
          zone_id     = var.certificates[cert_key].zone_id
          zone_name   = var.certificates[cert_key].zone_name
        }
      ]
    ]) : item.key => item if item.create
  }
}

data "aws_route53_zone" "this" {
  for_each = local.zone_name_lookups

  name         = each.value
  private_zone = false
}

# ==============================================================================
# Certificates
# ==============================================================================
resource "aws_acm_certificate" "this" {
  for_each = var.certificates

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method
  key_algorithm             = each.value.key_algorithm

  options {
    certificate_transparency_logging_preference = coalesce(
      try(each.value.options.certificate_transparency_logging_preference, null),
      each.value.certificate_transparency_logging_preference,
      "ENABLED"
    )
  }

  dynamic "validation_option" {
    for_each = each.value.validation_option
    content {
      domain_name       = validation_option.value.domain_name
      validation_domain = validation_option.value.validation_domain
    }
  }

  tags = merge(
    { Name = local.certificate_names[each.key] },
    each.value.tags,
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# DNS Validation Records
# ==============================================================================
resource "aws_route53_record" "validation" {
  for_each = local.validation_records

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id = (
    each.value.zone_id != null ? each.value.zone_id : data.aws_route53_zone.this[each.value.zone_name].zone_id
  )
}

resource "aws_acm_certificate_validation" "this" {
  for_each = {
    for k, v in var.certificates : k => v
    if v.wait_for_validation && v.create_route53_records && v.validation_method == "DNS"
  }

  certificate_arn = aws_acm_certificate.this[each.key].arn
  validation_record_fqdns = [
    for record_key, record in local.validation_records :
    aws_route53_record.validation[record_key].fqdn if record.cert_key == each.key
  ]

  timeouts {
    create = each.value.validation_timeout
  }
}

# ==============================================================================
# Imported Certificates
# ==============================================================================
resource "aws_acm_certificate" "imported" {
  for_each = var.imported_certificates

  private_key       = each.value.private_key
  certificate_body  = each.value.certificate_body
  certificate_chain = each.value.certificate_chain

  tags = merge(
    { Name = local.imported_certificate_names[each.key] },
    each.value.tags,
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
