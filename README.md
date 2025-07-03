# Keboola Transformation Module

This Terraform module creates and manages a Keboola component configuration, typically used for transformations (Snowflake SQL, BigQuery SQL, Python). It allows for dynamic configuration of scripts, input/output storage, and other parameters.

## Features

- Supports Snowflake, Google BigQuery, and Python transformations.
- Dynamically configures transformation blocks and scripts based on provided script files.
- Allows optional configuration of input and output storage mapping.
- Handles multiple scripts, each with its own block and code name.

## Usage Example

To use this module, create a `.tf` file (e.g., `main.tf` in your project root) and add the following:

```hcl
module "my_snowflake_transformation" {
  source = "./transformation" # Or path to this module

  resource_name = "My Snowflake Transformation"
  component_id  = "keboola.snowflake-transformation"
  description   = "This transformation processes raw data into an aggregated table."

  scripts = [
    {
      path       = "scripts/my_snowflake_query1.sql"
      block_name = "Block 1"
      code_name  = "Script 1"
    },
    {
      path       = "scripts/my_snowflake_query2.sql"
      block_name = "Block 2"
      code_name  = "Script 2"
    }
  ]

  # Optional: Define output tables
  output_tables = [
    {
      destination = "out.c-my-transformation.processed-data"
      source      = "processed_data_table"
      primary_key = ["ID"]
    }
  ]

  # Optional: Define input tables
  # input_tables = [
  #   {
  #     source      = "in.c-some-bucket.input-table"
  #     destination = "input_table.csv"
  #     columns     = []
  #     where_column = ""
  #     where_values = []
  #     where_operator = "eq"
  #   }
  # ]
}

# Example script file: scripts/my_snowflake_query.sql
# -- Block 1: Create a new table
# CREATE TABLE "processed_data_table" AS
# SELECT
#   "ID",
#   COUNT(*) AS "event_count"
# FROM "in.c-some-bucket.input-table"
# GROUP BY "ID";
#
# -- Block 2: Add some more data (example of multiple statements)
# INSERT INTO "processed_data_table" ("ID", "event_count")
# VALUES (100, 5);

## Scripts Variable Details

The `scripts` variable is a list of script objects, each specifying:
- `path`: Path to the script file (relative to this module)
- `block_name`: Name for the transformation block
- `code_name`: Name for the code/script within the block

**Behavior:**
- Multiple script objects with the same `block_name` and `code_name` will be combined into a single code block, and their contents merged.
- For SQL transformations (Snowflake, BigQuery), each script file is split by semicolon (`;`), and each statement becomes a separate element in the script array for that code block.
- For Python transformations, the entire file content is used as a single script string (no splitting).

**Example for SQL transformation:**
```hcl
scripts = [
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
```
All scripts with `block_name = "Block 1"` and `code_name = "Script 1"` will be merged into a single code block, and each SQL statement (split by `;`) will be a separate element in the script array.

**Example for Python transformation:**
```hcl
scripts = [
  {
    path       = "scripts/my_script.py"
    block_name = "Block 1"
    code_name  = "Main"
  }
]
```
The entire file content will be used as a single script string in the script array.

## Inputs

| Name            | Description                                                                                                         | Type     | Default   | Required |
|-----------------|---------------------------------------------------------------------------------------------------------------------|----------|-----------|----------|
| `resource_name` | Name of the Keboola component configuration resource. Also used in naming output tables if applicable.                | `string` |           | yes      |
| `component_id`  | Identifier of the Keboola component (e.g., 'keboola.snowflake-transformation').                                       | `string` |           | yes      |
| `description`   | Optional description for the Keboola component configuration.                                                         | `string` | `null`    | no       |
| `scripts`       | List of script objects, each with `path`, `block_name`, and `code_name`.                                              | `list(object)` | `[]` | no       |
| `input_tables`  | Optional list of input table configurations. Refer to Keboola documentation for structure.                          | `any`    | `null`    | no       |
| `output_tables` | Optional list of output table configurations. Refer to Keboola documentation for structure.                         | `any`    | `null`    | no       |

## Outputs

| Name                 | Description                                                                        |
|----------------------|------------------------------------------------------------------------------------|
| `id`                 | The ID of the created Keboola component configuration.                             |
| `name`               | The name of the Keboola component configuration as set in Keboola.                 |
| `component_id`       | The component ID used for this configuration.                                      |
| `version`            | The version number of the created Keboola component configuration.                 |
| `change_description` | The change description associated with the latest version of the configuration.    |

## Script Handling

- Each entry in the `scripts` variable is treated as a separate transformation block.
- For `keboola.python-transformation-v2`, the entire content of the file specified by `path` is treated as a single script.
- For SQL-based transformations (e.g., `keboola.snowflake-transformation`, `keboola.google-bigquery-transformation`), the content of the file specified by `path` is treated as a single code block. If you need to split scripts by semicolons, do so in your script file or create multiple script objects. 