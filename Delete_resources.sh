#!/bin/bash

# Check if the required argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: ./delete_resources.sh <namespace>"
  exit 1
fi

namespace=$1

# Validate namespace argument
if ! oc get project "$namespace" > /dev/null 2>&1; then
  echo "Namespace $namespace not found"
  exit 1
fi

# File containing resources to delete (one per line)
input_file="resources_to_delete.txt"

# Check if input file exists
if [ ! -f "$input_file" ]; then
  echo "Input file $input_file not found"
  exit 1
fi

# Loop through each line in the input file
while IFS= read -r resource; do
  if [ -z "$resource" ]; then
    continue
  fi

  # Check and delete each resource type
  case "$resource" in
    deployment* )
      deployment_name=$(echo "$resource" | cut -d' ' -f2)
      echo "Deleting Deployment: $deployment_name"
      oc delete deployment "$deployment_name" -n "$namespace"
      ;;
    route* )
      route_name=$(echo "$resource" | cut -d' ' -f2)
      echo "Deleting Route: $route_name"
      oc delete route "$route_name" -n "$namespace"
      ;;
    service* )
      service_name=$(echo "$resource" | cut -d' ' -f2)
      echo "Deleting Service: $service_name"
      oc delete service "$service_name" -n "$namespace"
      ;;
    secret* )
      secret_name=$(echo "$resource" | cut -d' ' -f2)
      echo "Deleting Secret: $secret_name"
      oc delete secret "$secret_name" -n "$namespace"
      ;;
    * )
      echo "Unknown resource type: $resource"
      ;;
  esac
done < "$input_file"

echo "Deletion process completed"
