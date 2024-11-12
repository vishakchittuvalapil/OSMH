#!/bin/bash

# Root compartment OCID
ROOT_COMPARTMENT_ID="<tenancy_ocid>"

process_compartment() {
  local compartment_id=$1
  local compartment_name=$2
  output_file="report_${compartment_name}.csv"
  
  oci os-management-hub managed-instance get-analytic-content \
    --file "$output_file" \
    --compartment-id "$compartment_id"
  
  if [ -s "$output_file" ]; then
    tail -n +2 "$output_file" | while IFS= read -r line; do
      echo "\"$compartment_name\",$line" >> consolidated_report.csv
    done
  fi
  rm "$output_file"

  oci iam compartment list --compartment-id "$compartment_id" --all \
    --query "data[?\"lifecycle-state\" == 'ACTIVE'].[name, id]" --output json \
    | jq -c '.[]' | while read -r subcompartment; do
      sub_name=$(echo "$subcompartment" | jq -r '.[0]')
      sub_id=$(echo "$subcompartment" | jq -r '.[1]')
      process_compartment "$sub_id" "$sub_name"
  done
}

echo "Compartment,Instance,\"Managed Instance Group\",\"Lifecycle Environment\",\"Lifecycle Stage\",Location,\"OS Version\",\"Security Updates Up To Date\",\"Security Advisory/Update Count\",\"Available Security Advisories/Updates\",\"Bugfix Updates Up To Date\",\"Bugfix Advisory/Update Count\",\"Available Bugfix Advisories/Updates\",Status,\"Last Check-In Time\"" > consolidated_report.csv

process_compartment "$ROOT_COMPARTMENT_ID" "root_compartment"
echo "Consolidated report generated: consolidated_report.csv"
