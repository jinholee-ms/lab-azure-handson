# 전역 고유 이름 보장을 위한 랜덤 suffix
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# ---------------------------------------------------------------------------
# App Service (Linux, public)
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "this" {
  name                = "${var.prefix}-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

resource "azurerm_linux_web_app" "this" {
  name                = "${var.prefix}-app-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_service_plan.this.location
  service_plan_id     = azurerm_service_plan.this.id

  # public 접근 허용
  public_network_access_enabled = true
  https_only                    = true

  site_config {
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    # App 에서 Cosmos DB 로 연결할 때 사용
    COSMOS_DB_ENDPOINT = azurerm_cosmosdb_account.this.endpoint
  }
}

# ---------------------------------------------------------------------------
# Cosmos DB (SQL API, public)
# ---------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "this" {
  name                = "${var.prefix}-cosmos-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # public 접근 허용 (모든 네트워크에서 접근 가능)
  public_network_access_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.this.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = "appdb"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
}

resource "azurerm_cosmosdb_sql_container" "this" {
  name                = "items"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  partition_key_paths = ["/id"]
}
