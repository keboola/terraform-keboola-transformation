locals {
  # Read script content if a path is provided. The path is relative to this module's directory.
  script_content = var.sql_script_path != null ? file(var.sql_script_path) : null

  # Process scripts based on component type.
  # For Python transformations, the entire file content is treated as a single script.
  # For SQL-like transformations, the content is split by semicolons, and each part is treated as a separate script.
  scripts_list = var.sql_script_path == null || local.script_content == null ? [] : (
    var.component_id == "keboola.python-transformation-v2" ? [local.script_content] :
    # SQL-like processing: split by ';', trim, re-add ';', and filter empty statements.
    # This handles cases where the script might end with a semicolon, leading to an empty last part after split.
    compact([
      for idx, part_content in split(";", local.script_content) :
      (idx == length(split(";", local.script_content)) - 1 && trimspace(part_content) == "") ? null : "${trimspace(part_content)};"
    ])
  )

  # Construct the configuration map for jsonencode.
  # Parameters (blocks and codes) are included only if a script is provided and processed successfully (scripts_list is not empty).
  # Storage (input/output tables) is included only if corresponding variables are provided.
  dynamic_configuration = {
    parameters = var.sql_script_path != null && length(local.scripts_list) > 0 ? {
      blocks = [
        {
          name = var.block_name
          codes = [
            {
              name   = var.code_name
              script = local.scripts_list # Must be a list of strings
            }
          ]
        }
      ]
    } : null # Parameters block is null if no script or empty script list

    storage = (var.input_tables != null || var.output_tables != null) ? {
      input  = var.input_tables  # jsonencode will omit this field if var.input_tables is null
      output = var.output_tables # jsonencode will omit this field if var.output_tables is null
    } : null # Storage block is null if neither input_tables nor output_tables are provided
  }
}

resource "keboola_component_configuration" "this" {
  name         = var.resource_name
  component_id = var.component_id
  description  = var.description # Terraform handles null description appropriately (omits or sets as empty based on provider)

  # The configuration argument expects a JSON string.
  # local.dynamic_configuration is a map that will be converted to JSON.
  # Null fields within this map (e.g., parameters or storage if not applicable) will be omitted by jsonencode,
  # resulting in a clean JSON structure as expected by the Keboola API.
  configuration = jsonencode(local.dynamic_configuration)
} 