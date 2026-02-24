#!/bin/bash
# ==============================================================================
# Generate env/cluster tfvars for one AKS cluster state
# Usage:
#   make gen-aks ENVIRONMENT=dev CLUSTER_KEY=cluster-v134 KUBERNETES_VERSION=1.34
#   ENVIRONMENT=dev CLUSTER_KEY=cluster-v134 ACTION=remove ./scripts/gen-aks.sh
# ==============================================================================

set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-${1:-}}"
if [ -z "${ENVIRONMENT}" ]; then
  echo "ERROR: ENVIRONMENT is required (dev|stg|prd)."
  exit 1
fi

case "${ENVIRONMENT}" in
  dev|stg|prd) ;;
  *)
    echo "ERROR: ENVIRONMENT must be one of: dev, stg, prd"
    exit 1
    ;;
esac

CLUSTER_KEY="${CLUSTER_KEY:-${CLUSTER_NAME:-}}"
if [ -z "${CLUSTER_KEY}" ]; then
  echo "ERROR: CLUSTER_KEY (or CLUSTER_NAME) is required."
  exit 1
fi

ACTION="${ACTION:-upsert}"
if [[ "${ACTION}" != "upsert" && "${ACTION}" != "remove" ]]; then
  echo "ERROR: ACTION must be either 'upsert' or 'remove'."
  exit 1
fi

WORKLOAD="${WORKLOAD:-tngs-aks}"
LOCATION="${LOCATION:-francecentral}"
LOCATION_SHORT="${LOCATION_SHORT:-frc}"
INSTANCE="${INSTANCE:-001}"
TEAM="${TEAM:-platform}"
PROJECT="${PROJECT:-tngs}"
TFSTATE_RESOURCE_GROUP_NAME="${TFSTATE_RESOURCE_GROUP_NAME:-rg-tngs-hub-prd-frc-001-tfstate}"
TFSTATE_STORAGE_ACCOUNT_NAME="${TFSTATE_STORAGE_ACCOUNT_NAME:-tfsttgnsprdfrc1}"
BACKEND_CONTAINER_NAME="${BACKEND_CONTAINER_NAME:-aks-${ENVIRONMENT}}"
BACKEND_KEY="${BACKEND_KEY:-aks/${ENVIRONMENT}/${CLUSTER_KEY}/terraform.tfstate}"
SPOKE_STATE_CONTAINER_NAME="${SPOKE_STATE_CONTAINER_NAME:-spoke-${ENVIRONMENT}}"
SPOKE_STATE_KEY="${SPOKE_STATE_KEY:-terraform.tfstate}"
KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.34}"
PRIVATE_CLUSTER_ENABLED="${PRIVATE_CLUSTER_ENABLED:-true}"
AZURE_RBAC_ENABLED="${AZURE_RBAC_ENABLED:-true}"
AKS_ADMIN_GROUP_NAME="${AKS_ADMIN_GROUP_NAME:-}"
AKS_ADMIN_GROUP_OBJECT_ID="${AKS_ADMIN_GROUP_OBJECT_ID:-}"
READ_ADMIN_GROUP_FROM_APP_CONFIGURATION="${READ_ADMIN_GROUP_FROM_APP_CONFIGURATION:-true}"
SOURCE_APP_CONFIGURATION_NAME="${SOURCE_APP_CONFIGURATION_NAME:-}"
SOURCE_APP_CONFIGURATION_RESOURCE_GROUP_NAME="${SOURCE_APP_CONFIGURATION_RESOURCE_GROUP_NAME:-}"
SYSTEM_NODE_VM_SIZE="${SYSTEM_NODE_VM_SIZE:-Standard_D4s_v5}"

if [ "${ENVIRONMENT}" = "prd" ]; then
  DEFAULT_NODE_COUNT=3
  CRITICALITY_DEFAULT="high"
else
  DEFAULT_NODE_COUNT=2
  CRITICALITY_DEFAULT="${ENVIRONMENT/dev/low}"
  CRITICALITY_DEFAULT="${CRITICALITY_DEFAULT/stg/medium}"
fi
SYSTEM_NODE_COUNT="${SYSTEM_NODE_COUNT:-${DEFAULT_NODE_COUNT}}"
CRITICALITY="${CRITICALITY:-${CRITICALITY_DEFAULT}}"

case "${ENVIRONMENT}" in
  dev) AKS_SUBNET_DEFAULT="snet-aks-tngs-dev-frc-001" ;;
  stg) AKS_SUBNET_DEFAULT="snet-aks-tngs-stg-frc-001" ;;
  prd) AKS_SUBNET_DEFAULT="snet-aks-tngs-prd-frc-001" ;;
esac

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$(az account show --query id -o tsv 2>/dev/null || true)}"
if [ -z "${SUBSCRIPTION_ID}" ]; then
  echo "ERROR: SUBSCRIPTION_ID is empty. Run 'make az-switch' first or pass SUBSCRIPTION_ID=..."
  exit 1
fi
AKS_SUBNET_NAME="${AKS_SUBNET_NAME:-${AKS_SUBNET_DEFAULT}}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-${PROJECT}-aks-${ENVIRONMENT}-${LOCATION_SHORT}-${INSTANCE}}"
NODE_RESOURCE_GROUP_NAME="${NODE_RESOURCE_GROUP_NAME:-rg-${PROJECT}-aks-${ENVIRONMENT}-${LOCATION_SHORT}-${INSTANCE}-${CLUSTER_KEY}-vmss}"

case "${PRIVATE_CLUSTER_ENABLED}" in
  true|false) ;;
  *)
    echo "ERROR: PRIVATE_CLUSTER_ENABLED must be 'true' or 'false'."
    exit 1
    ;;
esac

if [ "${ACTION}" = "remove" ]; then
  CLUSTER_ENABLED="false"
else
  CLUSTER_ENABLED="true"
fi

if [ "${ACTION}" != "remove" ] && [ "${AZURE_RBAC_ENABLED}" = "true" ] && [ "${READ_ADMIN_GROUP_FROM_APP_CONFIGURATION}" != "true" ]; then
  if [ -z "${AKS_ADMIN_GROUP_OBJECT_ID}" ] && [ -n "${AKS_ADMIN_GROUP_NAME}" ]; then
    AKS_ADMIN_GROUP_OBJECT_ID="$(az ad group show --group "${AKS_ADMIN_GROUP_NAME}" --query id -o tsv 2>/dev/null || true)"
  fi

  if [ -z "${AKS_ADMIN_GROUP_OBJECT_ID}" ]; then
    echo "ERROR: Set AKS_ADMIN_GROUP_OBJECT_ID (or AKS_ADMIN_GROUP_NAME resolvable via az ad)."
    exit 1
  fi
fi

OUT_DIR="envs/aks"
TFVARS_DIR="${OUT_DIR}/tfvars"
BACKENDS_DIR="${OUT_DIR}/backends"
ENV_TFVARS_JSON="${TFVARS_DIR}/aks-${ENVIRONMENT}.auto.tfvars.json"
CLUSTER_TFVARS_JSON="${TFVARS_DIR}/aks-${ENVIRONMENT}-${CLUSTER_KEY}.auto.tfvars.json"
BACKEND_FILE="${BACKENDS_DIR}/${ENVIRONMENT}-${CLUSTER_KEY}.backend.hcl"

mkdir -p "${TFVARS_DIR}" "${BACKENDS_DIR}"

export SUBSCRIPTION_ID TFSTATE_RESOURCE_GROUP_NAME TFSTATE_STORAGE_ACCOUNT_NAME
export BACKEND_CONTAINER_NAME BACKEND_KEY BACKEND_FILE

python3 - <<'PY'
import os
import re
from pathlib import Path

context = {
    "subscription_id": os.environ["SUBSCRIPTION_ID"],
    "tfstate_resource_group_name": os.environ["TFSTATE_RESOURCE_GROUP_NAME"],
    "tfstate_storage_account_name": os.environ["TFSTATE_STORAGE_ACCOUNT_NAME"],
    "backend_container_name": os.environ["BACKEND_CONTAINER_NAME"],
    "backend_key": os.environ["BACKEND_KEY"],
}
pattern = re.compile(r"{{\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*}}")

def render_file(src: Path, dst: Path) -> None:
    text = src.read_text(encoding="utf-8")
    def repl(match):
        key = match.group(1)
        if key not in context:
            raise KeyError(f"Missing template variable: {key}")
        return context[key]
    dst.write_text(pattern.sub(repl, text), encoding="utf-8")

render_file(Path("envs/aks/templates/backend.hcl.j2"), Path("envs/aks/backend.hcl"))
render_file(Path("envs/aks/templates/backend.hcl.j2"), Path(os.environ["BACKEND_FILE"]))
PY

STATE_EXISTS=false
if terraform -chdir="${OUT_DIR}" init -reconfigure -backend-config="${BACKEND_FILE}" -input=false -no-color >/dev/null 2>&1; then
  if terraform -chdir="${OUT_DIR}" state show "azurerm_kubernetes_cluster.this[0]" >/dev/null 2>&1; then
    STATE_EXISTS=true
  fi
else
  echo "WARN: Unable to initialize Terraform backend for state check. Continuing with local desired config only."
fi

export WORKLOAD ENVIRONMENT LOCATION LOCATION_SHORT INSTANCE TEAM PROJECT CRITICALITY
export RESOURCE_GROUP_NAME SUBSCRIPTION_ID TFSTATE_RESOURCE_GROUP_NAME TFSTATE_STORAGE_ACCOUNT_NAME
export SPOKE_STATE_CONTAINER_NAME SPOKE_STATE_KEY ENV_TFVARS_JSON
export CLUSTER_KEY CLUSTER_ENABLED AKS_SUBNET_NAME KUBERNETES_VERSION PRIVATE_CLUSTER_ENABLED
export AZURE_RBAC_ENABLED AKS_ADMIN_GROUP_OBJECT_ID
export READ_ADMIN_GROUP_FROM_APP_CONFIGURATION SOURCE_APP_CONFIGURATION_NAME SOURCE_APP_CONFIGURATION_RESOURCE_GROUP_NAME
export SYSTEM_NODE_COUNT SYSTEM_NODE_VM_SIZE NODE_RESOURCE_GROUP_NAME CLUSTER_TFVARS_JSON

python3 - <<'PY'
import json
import os
import re
from pathlib import Path

pattern = re.compile(r"{{\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*}}")

def render_template(template_path: str, output_path: str, context: dict) -> None:
    text = Path(template_path).read_text(encoding="utf-8")
    rendered = pattern.sub(lambda m: str(context[m.group(1)]), text)
    Path(output_path).write_text(rendered + "\n", encoding="utf-8")

env_context = {
    "workload": os.environ["WORKLOAD"],
    "environment": os.environ["ENVIRONMENT"],
    "location": os.environ["LOCATION"],
    "location_short": os.environ["LOCATION_SHORT"],
    "instance": os.environ["INSTANCE"],
    "subscription_id": os.environ["SUBSCRIPTION_ID"],
    "resource_group_name": os.environ["RESOURCE_GROUP_NAME"],
    "tfstate_resource_group_name": os.environ["TFSTATE_RESOURCE_GROUP_NAME"],
    "tfstate_storage_account_name": os.environ["TFSTATE_STORAGE_ACCOUNT_NAME"],
    "spoke_state_container_name": os.environ["SPOKE_STATE_CONTAINER_NAME"],
    "spoke_state_key": os.environ["SPOKE_STATE_KEY"],
    "team": os.environ["TEAM"],
    "project": os.environ["PROJECT"],
    "criticality": os.environ["CRITICALITY"],
}

cluster_context = {
    "cluster_name": os.environ["CLUSTER_KEY"],
    "cluster_enabled": os.environ["CLUSTER_ENABLED"],
    "aks_subnet_name": os.environ["AKS_SUBNET_NAME"],
    "kubernetes_version": os.environ["KUBERNETES_VERSION"],
    "private_cluster_enabled": os.environ["PRIVATE_CLUSTER_ENABLED"],
    "azure_rbac_enabled": os.environ["AZURE_RBAC_ENABLED"],
    "aks_admin_group_object_ids_json": (
        "[]" if os.environ["AKS_ADMIN_GROUP_OBJECT_ID"] == "" else "[\"%s\"]" % os.environ["AKS_ADMIN_GROUP_OBJECT_ID"]
    ),
    "read_admin_group_from_app_configuration": os.environ["READ_ADMIN_GROUP_FROM_APP_CONFIGURATION"],
    "source_app_configuration_name_json": (
        "null" if os.environ["SOURCE_APP_CONFIGURATION_NAME"] == "" else json.dumps(os.environ["SOURCE_APP_CONFIGURATION_NAME"])
    ),
    "source_app_configuration_resource_group_name_json": (
        "null" if os.environ["SOURCE_APP_CONFIGURATION_RESOURCE_GROUP_NAME"] == "" else json.dumps(os.environ["SOURCE_APP_CONFIGURATION_RESOURCE_GROUP_NAME"])
    ),
    "system_node_count": os.environ["SYSTEM_NODE_COUNT"],
    "system_node_vm_size": os.environ["SYSTEM_NODE_VM_SIZE"],
    "node_resource_group_name": os.environ["NODE_RESOURCE_GROUP_NAME"],
}

render_template("envs/aks/templates/terraform.tfvars.json.j2", os.environ["ENV_TFVARS_JSON"], env_context)
render_template("envs/aks/templates/cluster.auto.tfvars.json.j2", os.environ["CLUSTER_TFVARS_JSON"], cluster_context)
render_template("envs/aks/templates/cluster.auto.tfvars.json.j2", "envs/aks/terraform.tfvars.json", cluster_context)
PY

echo ">>> Generated envs/aks/backend.hcl"
echo ">>> Generated ${BACKEND_FILE}"
echo ">>> Generated ${ENV_TFVARS_JSON}"
echo ">>> Generated ${CLUSTER_TFVARS_JSON}"

if [ "${STATE_EXISTS}" = "true" ]; then
  echo ">>> TFSTATE check: cluster exists in state ${BACKEND_KEY}."
else
  echo ">>> TFSTATE check: cluster does not exist in state ${BACKEND_KEY}."
fi
