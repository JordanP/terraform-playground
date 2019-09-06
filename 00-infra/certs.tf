resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = "jordan@rezel.net"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = local.dns_zone
  subject_alternative_names = ["*.${local.dns_zone}"]

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT         = local.project_id
      GCE_SERVICE_ACCOUNT = file("../account.json")
    }
  }
}