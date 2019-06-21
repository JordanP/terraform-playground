resource "random_id" "sql_instance_name" {
  byte_length = 4
}

resource "google_sql_database_instance" "default" {
  name             = "master-gitlab-${random_id.sql_instance_name.hex}"
  database_version = "POSTGRES_9_6"
  region           = "europe-west4"

  settings {
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

resource "random_id" "postgres_gitlab_password" {
  byte_length = 8
}

resource "google_sql_user" "gitlab_user" {
  name     = "gitlab"
  instance = google_sql_database_instance.default.name
  password = random_id.postgres_gitlab_password.hex
}

resource "google_sql_database" "gitlab_database" {
  instance = google_sql_database_instance.default.name
  name     = "gitlab"
}

output "postgresql_host" {
  value = google_sql_database_instance.default.first_ip_address
}

output "postgresql_gitlab_database" {
  value = google_sql_database.gitlab_database.name
}

output "postgresql_gitlab_password" {
  value     = random_id.postgres_gitlab_password.hex
  sensitive = true
}
