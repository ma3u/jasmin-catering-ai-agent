output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.main.location
}

output "logic_app_id" {
  description = "ID of the Logic App Workflow"
  value       = azurerm_logic_app_workflow.email_processor.id
}

output "logic_app_name" {
  description = "Name of the Logic App Workflow"
  value       = azurerm_logic_app_workflow.email_processor.name
}

output "logic_app_access_endpoint" {
  description = "Access endpoint for the Logic App"
  value       = azurerm_logic_app_workflow.email_processor.access_endpoint
  sensitive   = true
}

output "azure_portal_url" {
  description = "URL to view the Logic App in Azure Portal"
  value       = "https://portal.azure.com/#resource${azurerm_logic_app_workflow.email_processor.id}"
}

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    environment          = var.environment
    location            = var.location
    logic_app_name      = var.logic_app_name
    email_filter        = var.webde_email_alias
    ai_model            = var.ai_model_deployment
    check_interval_min  = var.email_check_interval
    price_range_eur     = "${var.price_per_person_min}-${var.price_per_person_max}"
    guest_capacity      = "${var.min_guests}-${var.max_guests}"
  }
}

output "monitoring_command" {
  description = "Command to monitor the Logic App"
  value       = "az rest --method get --uri 'https://management.azure.com${azurerm_logic_app_workflow.email_processor.id}/runs?api-version=2019-05-01&$top=10'"
}