resource "random_id" "sql-instance-name" {
  byte_length = 4
}

resource "google_sql_database_instance" "default" {
  name             = "master-gitlab-${random_id.sql-instance-name.hex}"
  database_version = "POSTGRES_9_6"
  region           = "europe-west4"
  provider         = "google.default"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"

    availability_type = "ZONAL"
    disk_size         = "10"

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }

    ip_configuration {
      ipv4_enabled = "true"

      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "random_id" "postgres-gitlab-password" {
  byte_length = 8
}

resource "google_sql_user" "gitlab-user" {
  provider = "google.default"
  name     = "gitlab"
  instance = "${google_sql_database_instance.default.name}"
  password = "${random_id.postgres-gitlab-password.hex}"
}

resource "google_sql_database" "gitlab-db" {
  provider = "google.default"
  instance = "${google_sql_database_instance.default.name}"
  name     = "gitlab"
}

output "gitlab-dsn" {
  value = "postgres://gitlab:${random_id.postgres-gitlab-password.hex}@${google_sql_database_instance.default.first_ip_address}/gitlab"
}
