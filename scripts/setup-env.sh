export AKS_TENANT_ID=$(terraform -chdir=./infrastructure output -raw AKS_TENANT_ID)
export AKS_SUBSCRIPTION_ID=$(terraform -chdir=./infrastructure output -raw AKS_SUBSCRIPTION_ID)
export UMI_CLIENT_ID=$(terraform -chdir=./infrastructure output -raw UMI_CLIENT_ID)