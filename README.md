# Keboola Transformation Module

This Terraform module creates and manages a Keboola component configuration, typically used for transformations (Snowflake SQL, BigQuery SQL, Python). It allows for dynamic configuration of scripts, input/output storage, and other parameters.

## Features

- Supports Snowflake, Google BigQuery, and Python transformations.
- Dynamically configures transformation blocks and scripts based on a provided script file.
- Allows optional configuration of input and output storage mapping.
- Handles splitting of SQL scripts into multiple statements.

## Usage Example

To use this module, create a `.tf` file (e.g., `main.tf` in your project root) and add the following:

```hcl
module "my_snowflake_transformation" {
  source = "./transformation" # Or path to this module

  resource_name = "My Snowflake Transformation"
  component_id  = "keboola.snowflake-transformation"
  description   = "This transformation processes raw data into an aggregated table."

  sql_script_path = "scripts/my_snowflake_query.sql" # Path relative to the module's location

  # Optional: Define output tables
  output_tables = [
    {
      destination = "out.c-my-transformation.processed-data" # Example destination
      source      = "processed_data_table"                   # Must match table name in script if created
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

```

Make sure to create the script file (e.g., `transformation/scripts/my_snowflake_query.sql` if you place scripts inside the module directory, or adjust `sql_script_path` accordingly if it's elsewhere).

## Inputs

| Name                | Description                                                                                                         | Type     | Default   | Required |
|---------------------|---------------------------------------------------------------------------------------------------------------------|----------|-----------|----------|
| `resource_name`     | Name of the Keboola component configuration resource. Also used in naming output tables if applicable.                | `string` |           | yes      |
| `component_id`      | Identifier of the Keboola component (e.g., 'keboola.snowflake-transformation').                                       | `string` |           | yes      |
| `description`       | Optional description for the Keboola component configuration.                                                         | `string` | `null`    | no       |
| `sql_script_path`   | Path to the SQL/Python script file relative to this module's location (e.g., 'scripts/my_query.sql').                  | `string` | `null`    | no       |
| `block_name`        | Name for the transformation block (e.g., 'Main Block'). Used if `sql_script_path` is provided.                        | `string` | "Block 1" | no       |
| `code_name`         | Name for the code/script within the block (e.g., 'Run Script'). Used if `sql_script_path` is provided.                 | `string` | "Script"  | no       |
| `input_tables`      | Optional list of input table configurations. Refer to Keboola documentation for structure.                          | `any`    | `null`    | no       |
| `output_tables`     | Optional list of output table configurations. Refer to Keboola documentation for structure.                         | `any`    | `null`    | no       |

## Outputs

| Name                 | Description                                                                        |
|----------------------|------------------------------------------------------------------------------------|
| `id`                 | The ID of the created Keboola component configuration.                             |
| `name`               | The name of the Keboola component configuration as set in Keboola.                 |
| `component_id`       | The component ID used for this configuration.                                      |
| `version`            | The version number of the created Keboola component configuration.                 |
| `change_description` | The change description associated with the latest version of the configuration.    |

## Script Handling

- For `keboola.python-transformation-v2`, the entire content of the file specified by `sql_script_path` is treated as a single script.
- For SQL-based transformations (e.g., `keboola.snowflake-transformation`, `keboola.google-bigquery-transformation`), the content of the file specified by `sql_script_path` is split by semicolons (`;`). Each resulting part is treated as an individual script in the `codes` array. Empty statements resulting from trailing semicolons are automatically removed. Ensure each logical SQL command ends with a semicolon. 