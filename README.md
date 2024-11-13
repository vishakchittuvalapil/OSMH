# OSMH Instance Update Check for All Compartments

This repository contains a shell script to generate a consolidated report of managed instances in **Oracle OS Management Hub (OSMH)** across all compartments, including nested subcompartments. The output includes essential details about managed instances, along with the compartment name where each instance resides.

## Script Details

- **Script Name**: `osmh_instance_update_check_all_comp.sh`
- **Description**: This script recursively lists all compartments under a specified root compartment, retrieves analytic content for OSMH managed instances, and appends this data to a consolidated CSV file.
- **Output File**: `consolidated_report.csv`
  - This CSV file includes a **Compartment** column, followed by various details about each managed instance.

## Prerequisites

1. **Oracle CLI (oci)**: Ensure the Oracle CLI is installed and configured with appropriate credentials.
2. **jq**: Install `jq` to process JSON data.

## Usage Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/vishakchittuvalapil/OSMH.git
   cd OSMH-main

2.**Update Root Compartment OCID**:

Open the script file (osmh_instance_update_check_all_comp.sh).
Replace "<tenancy_ocid>" with your root compartment OCID.

3. **Run the Script**:
   ./osmh_instance_update_check_all_comp.sh

4. **Output:**
   A file named **consolidated_report.csv** will be generated in the same directory.
   Each row includes the Compartment name, instance details, and status information.Refer the **consolidated_report.csv** attached in the gihub for reference of sample output.
