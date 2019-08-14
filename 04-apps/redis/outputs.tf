output "redis_password" {
  value     = random_id.redis_password.hex
  sensitive = true
}
