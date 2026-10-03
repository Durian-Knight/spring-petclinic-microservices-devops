resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  version          = "65.5.1"
  create_namespace = false
  timeout          = 600

  values = [
    yamlencode({
      grafana = {
        adminPassword = var.grafana_admin_password
        service = {
          type = "ClusterIP"
        }
      }
      prometheus = {
        prometheusSpec = {
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false
          serviceMonitorNamespaceSelector          = {}
          podMonitorNamespaceSelector              = {}
        }
      }
    })
  ]
}

resource "kubernetes_config_map" "petclinic_dashboard" {
  metadata {
    name      = "petclinic-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "petclinic-dashboard.json" = file("${path.module}/../monitoring/dashboards/petclinic-dashboard.json")
  }
}

variable "grafana_admin_password" {
  description = "Grafana admin password (override with -var or TF_VAR_grafana_admin_password)"
  type        = string
  default     = "admin"
  sensitive   = true
}
