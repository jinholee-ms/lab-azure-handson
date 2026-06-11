output "resource_group_name" {
  description = "생성된 리소스 그룹 이름"
  value       = azurerm_resource_group.this.name
}

output "app_service_url" {
  description = "App Service 공개 URL"
  value       = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "cosmosdb_endpoint" {
  description = "Cosmos DB 엔드포인트"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "cosmosdb_primary_key" {
  description = "Cosmos DB primary key"
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}
