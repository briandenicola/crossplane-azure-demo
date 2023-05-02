SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
INFRA_PATH=$(realpath "${SCRIPT_DIR}/../infrastructure")

export APP_NAME=$(terraform -chdir=${INFRA_PATH} output -raw APP_NAME)
export RG=$(terraform -chdir=${INFRA_PATH} output -raw APP_RESOURCE_GROUP)

