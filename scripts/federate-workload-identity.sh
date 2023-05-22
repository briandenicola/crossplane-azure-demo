#!/bin/bash

while (( "$#" )); do
  case "$1" in
    -c|--cluster-name)
      CLUSTER_NAME=$2
      shift 2
      ;;
    -n|--namespace)
      NAMESPACE=$2
      shift 2
      ;;
    -a|--serviceaccount)
      SERVICE_ACCOUNT_NAME=$2
      shift 2
      ;;
    -i|--managed-identity)
      MANGED_IDENTITY_NAME=$2
      shift 2
      ;;
    -g|--resource-group)
      RG=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./federate-workload-identity.sh 
      Overview: This script will federate an Azure AD Managed Identity with a Kubernetes Service Account
        --cluster-name(c)     - The AKS cluster where this identity will be used
        --namespace(n)        - The Kuberentes namespace where this identity will be used
        --resource-group(g)   - The Resource Group where the Managed Identity lives
        --serviceaccount(a)   - The name of the Service Account to be federated
        --managed-identity(i) - The User Assigned Named Identity to be federated with
      "
      exit 0
      ;;
    --) 
      shift
      break
      ;;
    -*|--*=) 
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

CLUSTER_DETAILS=`az aks list --query "[?name=='${CLUSTER_NAME}']"`
CLUSTER_RG=`echo ${CLUSTER_DETAILS} | jq -r ".[].resourceGroup"`

SERVICE_ACCOUNT_ISSUER=`az aks show --resource-group ${CLUSTER_RG} --name ${CLUSTER_NAME} --query "oidcIssuerProfile.issuerUrl" -o tsv`
SUBJECT="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"

az identity federated-credential create \
  --name ${MANGED_IDENTITY_NAME} \
  --identity-name ${MANGED_IDENTITY_NAME} \
  --resource-group ${RG} \
  --issuer ${SERVICE_ACCOUNT_ISSUER} \
  --subject ${SUBJECT}