resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "acme_registration" "default" {
  account_key_pem = tls_private_key.default.private_key_pem
  email_address   = "jordan@rezel.net"
}

resource "acme_certificate" "default" {
  account_key_pem           = acme_registration.default.account_key_pem
  common_name               = local.dns_zone
  subject_alternative_names = ["*.${local.dns_zone}"]

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT             = local.project_id
      GCE_SERVICE_ACCOUNT     = file("../account.json")
      GCE_PROPAGATION_TIMEOUT = 180
    }
  }
}