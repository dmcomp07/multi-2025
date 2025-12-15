# Azure Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.cluster_name}-${var.environment}-rg"
  location = var.azure_region

  tags = var.common_tags
}

# Azure Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.cluster_name}-${var.environment}-vnet"
  address_space       = [var.vpc_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.common_tags
}

# Azure Subnet
resource "azurerm_subnet" "internal" {
  name                 = "${var.cluster_name}-${var.environment}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.3.0.0/16"]
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "secondary" {
  name                = "${var.cluster_name}-azure-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.cluster_name}-${var.environment}"
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name            = "default"
    node_count      = var.azure_node_count
    vm_size         = var.azure_vm_size
    vnet_subnet_id  = azurerm_subnet.internal.id
    max_surge       = 1
    os_disk_size_gb = 100
  }

  service_principal {
    client_id     = azurerm_service_principal.main.client_id
    client_secret = random_password.service_principal_password.result
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = var.common_tags

  depends_on = [azurerm_role_assignment.main]
}

# Azure Service Principal
resource "azurerm_service_principal" "main" {
  application_id = azurerm_ad_application.main.application_id
}

# Azure AD Application
resource "azurerm_ad_application" "main" {
  display_name = "${var.cluster_name}-${var.environment}"
}

# Service Principal Password
resource "random_password" "service_principal_password" {
  length  = 16
  special = true
}

# Service Principal Password
resource "azurerm_service_principal_password" "main" {
  service_principal_id = azurerm_service_principal.main.id
  value                = random_password.service_principal_password.result
  end_date_relative    = "8760h" # 1 year
}

# Role Assignment
resource "azurerm_role_assignment" "main" {
  scope              = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id       = azurerm_service_principal.main.object_id
}

# Azure SQL Database
resource "azurerm_mssql_server" "main" {
  name                         = "${replace(var.cluster_name, "-", "")}-${var.environment}-sqlserver"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_password.result

  tags = var.common_tags
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name           = "${var.cluster_name}-${var.environment}-db"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "S1"

  tags = var.common_tags
}

# Random SQL password
resource "random_password" "sql_password" {
  length  = 16
  special = true
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${replace(var.cluster_name, "-", "")}${var.environment}sa"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.common_tags
}
