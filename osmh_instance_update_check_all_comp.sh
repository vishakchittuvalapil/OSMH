#!/bin/bash 

# Define your root compartment OCID
ROOT_COMPARTMENT_ID="ocid1.tenancy.oc1..aaaaaaaakxcj247rl2tyoc6bsmexmcnku6x6ze4p55lqfobmww2rnrjbksiq"

# Function to recursively process compartments
process_compartment() {
  local compartment_id=$1
  local compartment_name=$2

  echo "Running report for compartment: $compartment_name ($compartment_id)"
  
  # Use the compartment name in the output file name
  output_file="report_${compartment_name}.csv"

  # Run the OCI CLI command for the current compartment
  oci os-management-hub managed-instance get-analytic-content \
    --file "$output_file" \
    --compartment-id "$compartment_id"

  # Append data to the consolidated report if there is data
  if [ -s "$output_file" ]; then
    echo "Data for compartment $compartment_name appended to consolidated report."
    
    # Process each line in the temporary report, add the compartment name, and append to the consolidated file
    tail -n +2 "$output_file" | while IFS= read -r line; do
      echo "\"$compartment_name\",$line" >> consolidated_report.csv
    done
  else
    echo "No data found for compartment $compartment_name."
  fi

  # Clean up the individual report file
  rm "$output_file"

  # Retrieve a list of active subcompartments under the current compartment
  subcompartments=$(oci iam compartment list \
                    --compartment-id "$compartment_id" \
                    --all \
                    --query "data[?\"lifecycle-state\" == 'ACTIVE'].[name, id]" \
                    --output json)

  # Process each subcompartment
  echo "$subcompartments" | jq -c '.[]' | while read -r subcompartment; do
    subcompartment_name=$(echo "$subcompartment" | jq -r '.[0]')
    subcompartment_id=$(echo "$subcompartment" | jq -r '.[1]')

    # Recursively process each subcompartment
    process_compartment "$subcompartment_id" "$subcompartment_name"
  done
}

# Initialize the consolidated output file with headers, including "Compartment" as the first column
echo "Compartment,Instance,\"Managed Instance Group\",\"Lifecycle Environment\",\"Lifecycle Stage\",Location,\"OS Version\",\"Security Updates Up To Date\",\"Security Advisory/Update Count\",\"Available Security Advisories/Updates\",\"Bugfix Updates Up To Date\",\"Bugfix Advisory/Update Count\",\"Available Bugfix Advisories/Updates\",Status,\"Last Check-In Time\"" > consolidated_report.csv

# Start processing from the root compartment
process_compartment "$ROOT_COMPARTMENT_ID" "root_compartment"

echo "Consolidated report generated: consolidated_report.csv"
