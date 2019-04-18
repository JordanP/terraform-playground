resource "kubernetes_deployment" "test-app" {
  "metadata" {
    name = "test-app"
  }

  "spec" {
    replicas = 1

    selector {
      match_labels {
        app = "test-app"
      }
    }

    "template" {
      "metadata" {
        labels {
          app = "test-app"
        }
      }

      "spec" {
        container {
          name  = "echo"
          image = "k8s.gcr.io/echoserver:1.10"

          port {
            container_port = 8080
            name           = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "test-app" {
  "metadata" {
    name = "test-app"
  }

  "spec" {
    selector {
      app = "${kubernetes_deployment.test-app.metadata.0.name}"
    }

    port {
      port        = 8080
      target_port = "8080"
    }
  }
}

resource "google_dns_record_set" "app-record-a" {
  provider = "google.default"

  # DNS zone name
  managed_zone = "${local.dns_zone_name}"

  # DNS record
  name = "app.${local.dns_zone}."
  type = "A"
  ttl  = 300

  rrdatas = [
    "${module.google-cloud-jordan.ingress_static_ipv4}",
  ]
}

resource "google_dns_record_set" "monitoring" {
  provider = "google.default"

  # DNS zone name
  managed_zone = "${local.dns_zone_name}"

  # DNS record
  name = "monitoring.${local.dns_zone}."
  type = "A"
  ttl  = 300

  rrdatas = [
    "${module.google-cloud-jordan.ingress_static_ipv4}",
  ]
}

/*
KUBECONFIG=/home/jordan/.secrets/clusters/tf-playground/auth/kubeconfig ./kubectl apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    kubernetes.io/ingress.class: "public"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: app.jordanpittier.net
    http:
      paths:
      - backend:
          serviceName: test-app
          servicePort: 8080
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "public"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: monitoring.jordanpittier.net
    http:
      paths:
      - backend:
          serviceName: grafana
          servicePort: 80
EOF

*/

