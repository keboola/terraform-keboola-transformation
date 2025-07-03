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

variable "scripts" {
  description = "List of script objects, each specifying: path (relative to this module), block_name (transformation block name), and code_name (script name within the block). For details and usage examples, see the README.md. Multiple scripts with the same block_name and code_name are merged. For SQL, scripts are split by semicolon; for Python, the whole file is used as a single script."
  type = list(object({
    path       = string
    block_name = string
    code_name  = string
  }))
  default = []
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