#!/bin/bash
# ==============================================================================
# Generate envs/peering/spoke-hub backend/tfvars files from .j2 templates
# Usage:
#   make gen-spoke-hub SPOKE=spoke-dev
#   SPOKE=spoke-prd SUBSCRIPTION_ID=xxxx ./scripts/gen-spoke-hub.sh
# ==============================================================================

set -euo pipefail

SPOKE="${SPOKE:-${1:-}}"
if [ -z "${SPOKE}" ]; then
  echo "ERROR: SPOKE is required (example: SPOKE=spoke-dev)."
  exit 1
fi

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$(az account show --query id -o tsv 2>/dev/null || true)}"
if [ -z "${SUBSCRIPTION_ID}" ]; then
  echo "ERROR: SUBSCRIPTION_ID is empty. Run 'make az-switch' first or pass SUBSCRIPTION_ID=..."
  exit 1
fi

TFSTATE_RESOURCE_GROUP_NAME="${TFSTATE_RESOURCE_GROUP_NAME:-rg-tngs-hub-prd-frc-001-tfstate}"
TFSTATE_STORAGE_ACCOUNT_NAME="${TFSTATE_STORAGE_ACCOUNT_NAME:-tfsttgnsprdfrc1}"
BACKEND_CONTAINER_NAME="${BACKEND_CONTAINER_NAME:-peering}"
BACKEND_KEY="${BACKEND_KEY:-${SPOKE}/terraform.tfstate}"
SPOKE_STATE_CONTAINER_NAME="${SPOKE_STATE_CONTAINER_NAME:-${SPOKE}}"
SPOKE_STATE_KEY="${SPOKE_STATE_KEY:-terraform.tfstate}"
HUB_STATE_CONTAINER_NAME="${HUB_STATE_CONTAINER_NAME:-hub-tngs}"
HUB_STATE_KEY="${HUB_STATE_KEY:-terraform.tfstate}"
ALLOW_GATEWAY_TRANSIT="${ALLOW_GATEWAY_TRANSIT:-false}"
ALLOW_FORWARDED_TRAFFIC="${ALLOW_FORWARDED_TRAFFIC:-true}"

for b in "${ALLOW_GATEWAY_TRANSIT}" "${ALLOW_FORWARDED_TRAFFIC}"; do
  case "${b}" in
    true|false) ;;
    *)
      echo "ERROR: boolean values must be 'true' or 'false'."
      exit 1
      ;;
  esac
done

TEMPLATE_DIR="envs/peering/spoke-hub/templates"
OUT_DIR="envs/peering/spoke-hub"
TFVARS_DIR="${OUT_DIR}/tfvars"
BACKENDS_DIR="${OUT_DIR}/backends"

export SUBSCRIPTION_ID TFSTATE_RESOURCE_GROUP_NAME TFSTATE_STORAGE_ACCOUNT_NAME
export BACKEND_CONTAINER_NAME BACKEND_KEY SPOKE SPOKE_STATE_CONTAINER_NAME SPOKE_STATE_KEY
export HUB_STATE_CONTAINER_NAME HUB_STATE_KEY ALLOW_GATEWAY_TRANSIT ALLOW_FORWARDED_TRAFFIC

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
    "spoke_name": os.environ["SPOKE"],
    "spoke_state_container_name": os.environ["SPOKE_STATE_CONTAINER_NAME"],
    "spoke_state_key": os.environ["SPOKE_STATE_KEY"],
    "hub_state_container_name": os.environ["HUB_STATE_CONTAINER_NAME"],
    "hub_state_key": os.environ["HUB_STATE_KEY"],
    "allow_gateway_transit": os.environ["ALLOW_GATEWAY_TRANSIT"],
    "allow_forwarded_traffic": os.environ["ALLOW_FORWARDED_TRAFFIC"],
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


template_dir = Path("envs/peering/spoke-hub/templates")
out_dir = Path("envs/peering/spoke-hub")
tfvars_dir = out_dir / "tfvars"
backends_dir = out_dir / "backends"

tfvars_dir.mkdir(parents=True, exist_ok=True)
backends_dir.mkdir(parents=True, exist_ok=True)
spoke = context["spoke_name"]

# Compatibility files used by existing make targets
render_file(template_dir / "backend.hcl.j2", out_dir / "backend.hcl")
render_file(template_dir / "terraform.tfvars.j2", out_dir / "terraform.tfvars")

# Per-spoke files
render_file(template_dir / "backend.hcl.j2", backends_dir / f"{spoke}.backend.hcl")
render_file(template_dir / "terraform.tfvars.j2", tfvars_dir / f"{spoke}.tfvars")
PY

echo ">>> Generated ${OUT_DIR}/backend.hcl"
echo ">>> Generated ${OUT_DIR}/terraform.tfvars"
echo ">>> Generated ${BACKENDS_DIR}/${SPOKE}.backend.hcl"
echo ">>> Generated ${TFVARS_DIR}/${SPOKE}.tfvars"
