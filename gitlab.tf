module "gitlab" {
  source                = "./gitlab"
  helm_release_name     = "${local.gitlab_release_name}"
  postgresql_password   = "${random_id.postgres_gitlab_password.hex}"
  postgresql_host       = "${google_sql_database_instance.default.first_ip_address}"
  postgresql_database   = "${google_sql_database.gitlab_db.name}"
  force_destroy_buckets = "true"

  providers = {
    google = "google.default"
  }
}

resource "google_compute_firewall" "git_clone_ssh" {
  provider = "google.default"
  name     = "git-clone-ssh"
  network  = "${module.google-cloud-jordan.network_name}"

  allow {
    protocol = "TCP"

    ports = [
      8022,
    ]
  }

  target_tags = [
    "${local.cluster_name}-worker",
  ]
}

resource "google_compute_forwarding_rule" "gitlab" {
  provider   = "google.default"
  name       = "gitlab"
  target     = "${module.google-cloud-jordan.worker_target_pool}"
  port_range = "1-65535"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "kube-system"
  }
}

output "gitlab_initial_root_password" {
  value = "${module.gitlab.gitlab_initial_root_password}"
}
