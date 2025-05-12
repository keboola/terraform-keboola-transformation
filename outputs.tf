output "id" {
  description = "The ID of the created Keboola component configuration."
  value       = keboola_component_configuration.this.id
}

output "name" {
  description = "The name of the Keboola component configuration as set in Keboola."
  value       = keboola_component_configuration.this.name
}

output "component_id" {
  description = "The component ID used for this configuration (e.g., keboola.snowflake-transformation)."
  value       = keboola_component_configuration.this.component_id
}

output "change_description" {
  description = "The change description associated with the latest version of the configuration."
  value       = keboola_component_configuration.this.change_description
}

output "configuration_id" {
  description = "The configuration ID of the created Keboola component configuration."
  value       = keboola_component_configuration.this.configuration_id
} 