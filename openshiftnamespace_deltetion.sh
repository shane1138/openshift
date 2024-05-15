#!/bin/bash

# Function to delete all resources in a specified namespace
delete_namespace_resources() {
  local namespace=$1

  if [ -z "$namespace" ]; then
    echo "Namespace must be specified."
    return 1
  fi

  echo "Deleting resources in namespace: $namespace"

  # List of resource types to delete
  resource_types=(
    pods
    deployments
    replicasets
    statefulsets
    daemonsets
    jobs
    cronjobs
    services
    routes
    ingresses
    configmaps
    secrets
    pvc
    serviceaccounts
    rolebindings
    roles
    networkpolicies
    resourcequotas
    limitranges
    hpa
    pdb
    bc
    is
    templates
  )

  # Loop through each resource type and delete all resources of that type in the namespace
  for resource in "${resource_types[@]}"; do
    # Check if the resource type exists in the namespace
    resource_count=$(oc get $resource -n $namespace --ignore-not-found --no-headers | wc -l)
    if [ "$resource_count" -gt 0 ]; then
      echo "Deleting all $resource in namespace $namespace"
      oc delete $resource --all -n $namespace

      # Check if resources are actually deleted
      remaining_resources=$(oc get $resource -n $namespace --no-headers | wc -l)
      if [ "$remaining_resources" -ne 0 ]; then
        echo "Warning: Not all $resource were deleted in namespace $namespace. Remaining count: $remaining_resources"
        oc get $resource -n $namespace
      else
        echo "All $resource deleted successfully in namespace $namespace."
      fi
    else
      echo "No $resource found in namespace $namespace. Skipping."
    fi
  done

  # Delete the namespace itself
  echo "Deleting namespace: $namespace"
  oc delete namespace $namespace

  # Check if the namespace is actually deleted
  remaining_namespace=$(oc get namespace $namespace --ignore-not-found)
  if [ -n "$remaining_namespace" ]; then
    echo "Warning: Namespace $namespace was not deleted successfully."
  else
    echo "Namespace $namespace deleted successfully."
  fi
}

# Example usage:
# delete_namespace_resources "my-namespace"
