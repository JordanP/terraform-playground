data "google_kms_key_ring" "my_key_ring" {
  name     = "my-key-ring"
  location = "europe"
}

data "google_kms_crypto_key" "my_crypto_key" {
  name     = "my-crypto-key"
  key_ring = data.google_kms_key_ring.my_key_ring.self_link
}

output "my_crypto_key" {
  value = data.google_kms_crypto_key.my_crypto_key.self_link
}