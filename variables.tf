variable "resource_name" {
  description = "Name of the Keboola component configuration resource. This will also be used in naming output tables if applicable."
  type        = string
}

variable "component_id" {
  description = "Identifier of the Keboola component (e.g., 'keboola.snowflake-transformation')."
  type        = string
  validation {
    condition     = contains(["keboola.snowflake-transformation", "keboola.google-bigquery-transformation", "keboola.python-transformation-v2"], var.component_id)
    error_message = "Allowed values for component_id are 'keboola.snowflake-transformation', 'keboola.google-bigquery-transformation', or 'keboola.python-transformation-v2'."
  }
}

variable "description" {
  description = "Optional description for the Keboola component configuration."
  type        = string
  default     = null
}

variable "sql_script_path" {
  description = "Path to the SQL/Python script file relative to this module's location (e.g., 'scripts/my_query.sql'). If provided, transformation blocks will be configured."
  type        = string
  default     = null
}

variable "block_name" {
  description = "Name for the transformation block (e.g., 'Main Block'). Required and used only if 'sql_script_path' is provided."
  type        = string
  default     = "Block 1"
}

variable "code_name" {
  description = "Name for the code/script within the transformation block (e.g., 'Run Script'). Required and used only if 'sql_script_path' is provided."
  type        = string
  default     = "Script"
}

variable "input_tables" {
  description = "Optional list of input table configurations for the storage section. Refer to Keboola documentation for the exact structure."
  type        = any # Using 'any' for flexibility, user must ensure correct structure.
  default     = null
}

variable "output_tables" {
  description = "Optional list of output table configurations for the storage section. Refer to Keboola documentation for the exact structure."
  type        = any # Using 'any' for flexibility, user must ensure correct structure.
  default     = null
} 