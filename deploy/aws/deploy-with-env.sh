#!/usr/bin/env bash
# One-shot AWS deploy: loads OPENAI_API_KEY from repo .env, runs CloudFormation.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT}/.env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v aws >/dev/null 2>&1; then
  echo "AWS CLI not found. Install: brew install awscli"
  exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "AWS credentials not configured."
  echo "  Run:  aws configure"
  echo "  Or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, then re-run this script."
  exit 1
fi

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  read -r -s -p "OPENAI_API_KEY: " OPENAI_API_KEY
  echo
  export OPENAI_API_KEY
fi

export AWS_REGION="${AWS_REGION:-us-east-1}"
export REPO_URL="${REPO_URL:-https://github.com/lokeshadda/ai-incident-resolution.git}"
export REPO_BRANCH="${REPO_BRANCH:-main}"

if [[ -z "${KEY_PAIR:-}" ]]; then
  echo "Key pairs in ${AWS_REGION}:"
  aws ec2 describe-key-pairs --region "$AWS_REGION" \
    --query 'KeyPairs[*].KeyName' --output table
  read -r -p "EC2 KeyPairName: " KEY_PAIR
  export KEY_PAIR
fi

if [[ -z "${SSH_CIDR:-}" ]]; then
  MY_IP="$(curl -sf https://checkip.amazonaws.com 2>/dev/null || true)"
  if [[ -n "$MY_IP" ]]; then
    export SSH_CIDR="${MY_IP}/32"
    echo "SSH restricted to ${SSH_CIDR}"
  else
    export SSH_CIDR="0.0.0.0/0"
    echo "Warning: SSH open to 0.0.0.0/0"
  fi
fi

chmod +x "${SCRIPT_DIR}/deploy.sh" "${SCRIPT_DIR}/scripts/bootstrap.sh"
exec "${SCRIPT_DIR}/deploy.sh"
