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
  description = <<EOT
List of script objects, each specifying:
- path: Path to the script file (relative to this module)
- block_name: Name for the transformation block
- code_name: Name for the code/script within the block

**Behavior:**
- Multiple script objects with the same block_name and code_name will be combined into a single code block, and their contents merged.
- For SQL transformations (Snowflake, BigQuery), each script file is split by semicolon (`;`), and each statement becomes a separate element in the script array for that code block.
- For Python transformations, the entire file content is used as a single script string (no splitting).

**Example for SQL transformation:**
[
  {
    path       = "scripts/my_query1.sql"
    block_name = "Block 1"
    code_name  = "Script 1"
  },
  {
    path       = "scripts/my_query2.sql"
    block_name = "Block 1"
    code_name  = "Script 1"
  },
  {
    path       = "scripts/my_query3.sql"
    block_name = "Block 2"
    code_name  = "Script 2"
  }
]
# All scripts with block_name = "Block 1" and code_name = "Script 1" will be merged into a single code block, and each SQL statement (split by `;`) will be a separate element in the script array.

**Example for Python transformation:**
[
  {
    path       = "scripts/my_script.py"
    block_name = "Block 1"
    code_name  = "Main"
  }
]
# The entire file content will be used as a single script string in the script array.
EOT
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