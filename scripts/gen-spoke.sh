#!/bin/bash
# ==============================================================================
# Generate envs/spoke/backend.hcl and tfvars files from .j2 templates
# Usage:
#   make gen-spoke SPOKE=spoke-dev
#   SPOKE=spoke-prd SUBSCRIPTION_ID=xxxx ./scripts/gen-spoke.sh
# ==============================================================================

set -euo pipefail

SPOKE="${SPOKE:-${1:-}}"
if [ -z "${SPOKE}" ]; then
  echo "ERROR: SPOKE is required (example: SPOKE=spoke-dev)."
  exit 1
fi

if [[ "${SPOKE}" == spoke-* ]]; then
  ENVIRONMENT="${ENVIRONMENT:-${SPOKE#spoke-}}"
else
  ENVIRONMENT="${ENVIRONMENT:-dev}"
fi

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$(az account show --query id -o tsv 2>/dev/null || true)}"
if [ -z "${SUBSCRIPTION_ID}" ]; then
  echo "ERROR: SUBSCRIPTION_ID is empty. Run 'make az-switch' first or pass SUBSCRIPTION_ID=..."
  exit 1
fi

TFSTATE_RESOURCE_GROUP_NAME="${TFSTATE_RESOURCE_GROUP_NAME:-rg-tngs-hub-prd-frc-001-tfstate}"
TFSTATE_STORAGE_ACCOUNT_NAME="${TFSTATE_STORAGE_ACCOUNT_NAME:-tfsttgnsprdfrc1}"
BACKEND_CONTAINER_NAME="${BACKEND_CONTAINER_NAME:-${SPOKE}}"
BACKEND_KEY="${BACKEND_KEY:-terraform.tfstate}"

WORKLOAD="${WORKLOAD:-tngs-spoke}"
LOCATION="${LOCATION:-francecentral}"
LOCATION_SHORT="${LOCATION_SHORT:-frc}"
INSTANCE="${INSTANCE:-001}"
TEAM="${TEAM:-platform}"
PROJECT="${PROJECT:-tngs}"

ADDRESS_SPACE="${ADDRESS_SPACE:-10.1.0.0/16}"
AKS_SUBNET_PREFIX="${AKS_SUBNET_PREFIX:-10.1.0.0/22}"
APP_SUBNET_PREFIX="${APP_SUBNET_PREFIX:-10.1.4.0/24}"
DATA_SUBNET_PREFIX="${DATA_SUBNET_PREFIX:-10.1.5.0/24}"
CRITICALITY="${CRITICALITY:-low}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-${WORKLOAD}-${ENVIRONMENT}-${LOCATION_SHORT}-${INSTANCE}}"

TEMPLATE_DIR="envs/spoke/templates"
OUT_DIR="envs/spoke"
TFVARS_DIR="${OUT_DIR}/tfvars"
BACKENDS_DIR="${OUT_DIR}/backends"

export SUBSCRIPTION_ID TFSTATE_RESOURCE_GROUP_NAME TFSTATE_STORAGE_ACCOUNT_NAME
export BACKEND_CONTAINER_NAME BACKEND_KEY
export WORKLOAD ENVIRONMENT LOCATION LOCATION_SHORT INSTANCE TEAM PROJECT
export ADDRESS_SPACE AKS_SUBNET_PREFIX APP_SUBNET_PREFIX DATA_SUBNET_PREFIX CRITICALITY
export RESOURCE_GROUP_NAME
export SPOKE

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
    "workload": os.environ["WORKLOAD"],
    "environment": os.environ["ENVIRONMENT"],
    "location": os.environ["LOCATION"],
    "location_short": os.environ["LOCATION_SHORT"],
    "instance": os.environ["INSTANCE"],
    "team": os.environ["TEAM"],
    "project": os.environ["PROJECT"],
    "address_space": os.environ["ADDRESS_SPACE"],
    "aks_subnet_prefix": os.environ["AKS_SUBNET_PREFIX"],
    "app_subnet_prefix": os.environ["APP_SUBNET_PREFIX"],
    "data_subnet_prefix": os.environ["DATA_SUBNET_PREFIX"],
    "criticality": os.environ["CRITICALITY"],
    "resource_group_name": os.environ["RESOURCE_GROUP_NAME"],
    "spoke": os.environ["SPOKE"],
}

pattern = re.compile(r"{{\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*}}")

def render_file(src: Path, dst: Path) -> None:
    text = src.read_text(encoding="utf-8")

    def repl(match):
        key = match.group(1)
        if key not in context:
            raise KeyError(f"Missing template variable: {key}")
        return context[key]

    rendered = pattern.sub(repl, text)
    dst.write_text(rendered, encoding="utf-8")


template_dir = Path("envs/spoke/templates")
out_dir = Path("envs/spoke")
tfvars_dir = out_dir / "tfvars"
backends_dir = out_dir / "backends"

tfvars_dir.mkdir(parents=True, exist_ok=True)
backends_dir.mkdir(parents=True, exist_ok=True)

spoke = context["spoke"]
env = context["environment"]

# Compatibility files used by existing make targets
render_file(template_dir / "backend.hcl.j2", out_dir / "backend.hcl")
render_file(template_dir / "terraform.tfvars.j2", out_dir / "terraform.tfvars")

# Per-spoke files
render_file(template_dir / "backend.hcl.j2", backends_dir / f"{env}-backend.hcl")
render_file(template_dir / "terraform.tfvars.j2", tfvars_dir / f"{spoke}.tfvars")
PY

echo ">>> Generated ${OUT_DIR}/backend.hcl"
echo ">>> Generated ${OUT_DIR}/terraform.tfvars"
echo ">>> Generated ${BACKENDS_DIR}/${ENVIRONMENT}-backend.hcl"
echo ">>> Generated ${TFVARS_DIR}/${BACKEND_CONTAINER_NAME}.tfvars"
