variable "prefix" {
  description = "리소스 이름 prefix (전역 고유성 위해 짧게)"
  type        = string
  default     = "tftest005"
}

variable "location" {
  description = "Azure 리전"
  type        = string
  default     = "koreacentral"
}

variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B1"
}
