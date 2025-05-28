resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  node_resource_group = var.node_resource_group

 default_node_pool {
  name            = "agentpool"
  vm_size         = "Standard_D2s_v3"
  node_count      = var.node_count
  max_pods        = 110
  os_disk_size_gb = 128
  os_sku          = "Ubuntu"
}

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    service_cidrs      = ["10.0.0.0/16"]
    load_balancer_sku  = "standard"
  }
}

/*resource "azurerm_role_assignment" "role_acrpull" {
  scope                             = azurerm_container_registry.acr.id
  role_definition_name              = "AcrPull"
  principal_id                      = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}*/

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubectl_manifest" "service_a_deployment" {
  yaml_body  = file("${path.root}/../yaml/service-a-deployment.yaml")
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubectl_manifest" "service_a_service" {
  yaml_body  = file("${path.root}/../yaml/service-a-service.yaml")
  depends_on = [kubectl_manifest.service_a_deployment]
}

resource "kubectl_manifest" "service_b_deployment" {
  yaml_body  = file("${path.root}/../yaml/service-b-deployment.yaml")
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubectl_manifest" "service_b_service" {
  yaml_body  = file("${path.root}/../yaml/service-b-service.yaml")
  depends_on = [kubectl_manifest.service_b_deployment]
}

resource "kubectl_manifest" "ingress" {
  yaml_body  = file("${path.root}/../yaml/ingress.yaml")
  depends_on = [
    kubectl_manifest.service_a_service,
    kubectl_manifest.service_b_service,
    helm_release.nginx_ingress
  ]
}

resource "kubectl_manifest" "network_policy" {
  yaml_body  = file("${path.root}/../yaml/network-policy.yaml")
  depends_on = [
    kubectl_manifest.service_a_deployment,
    kubectl_manifest.service_b_deployment
  ]
}
