locals {
  # Read and process each script object in var.scripts.
  # Each script object contains: path (relative to module), block_name, code_name.
  scripts_content = [
    for script in var.scripts : {
      block_name = script.block_name
      code_name  = script.code_name
      content    = file(script.path)
    }
  ]

  # Get unique block names
  block_names = toset([for script in local.scripts_content : script.block_name])

  # For each block, get unique code names
  block_code_names = {
    for block_name in local.block_names :
    block_name => toset([
      for script in local.scripts_content : script.code_name
      if script.block_name == block_name
    ])
  }

  # Group scripts by block_name and code_name, and split each script file by semicolon for SQL, or keep as single string for Python
  blocks = [
    for block_name in local.block_names : {
      name  = block_name
      codes = [
        for code_name in local.block_code_names[block_name] : {
          name   = code_name
          script = [
            for s in (
              var.component_id == "keboola.python-transformation-v2"
                ? [
                    for script in local.scripts_content :
                    script.block_name == block_name && script.code_name == code_name ? script.content : null
                    if script.block_name == block_name && script.code_name == code_name
                  ]
                : flatten([
                    for script in local.scripts_content :
                    script.block_name == block_name && script.code_name == code_name ? [
                      for part in split(";", script.content) :
                      trimspace(part) != "" ? "${trimspace(part)};" : null
                    ] : []
                    if script.block_name == block_name && script.code_name == code_name
                  ])
            ) : s if s != null
          ]
        }
      ]
    }
  ]

  # Construct the configuration map for jsonencode.
  dynamic_configuration = {
    parameters = length(local.blocks) > 0 ? { blocks = local.blocks } : null
    storage    = (var.input_tables != null || var.output_tables != null) ? {
      input  = var.input_tables != null ? var.input_tables : {}
      output = var.output_tables != null ? var.output_tables : {}
    } : {}
  }
}

resource "keboola_component_configuration" "this" {
  name         = var.resource_name
  component_id = var.component_id
  description  = var.description # Terraform handles null description appropriately (omits or sets as empty based on provider)
  configuration = jsonencode(local.dynamic_configuration)
} 