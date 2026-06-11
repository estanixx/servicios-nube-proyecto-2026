#!/usr/bin/env bash
# Crea el bucket S3 para el estado de Terraform y genera backend.tf.
# Debe correrse UNA SOLA VEZ antes de 'terraform init'.
#
# Uso:
#   ./scripts/bootstrap-backend.sh
#   REGION=us-west-2 STATE_KEY=proyecto/terraform.tfstate ./scripts/bootstrap-backend.sh

set -euo pipefail

REGION="${REGION:-us-east-1}"
STATE_KEY="${STATE_KEY:-nexacloud/terraform.tfstate}"
TERRAFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"

if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI no encontrado. Instálalo y corre 'aws configure'." >&2
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="central-tfstate-${ACCOUNT_ID}"

echo "Cuenta AWS : $ACCOUNT_ID"
echo "Región     : $REGION"
echo "Bucket     : $BUCKET_NAME"
echo "State key  : $STATE_KEY"
echo

# Crear bucket (idempotente)
if aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
  echo "Bucket ya existe, omitiendo creación."
else
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$REGION"
  else
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi
  echo "Bucket creado."
fi

# Versioning (necesario para use_lockfile = true)
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Cifrado AES-256
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"},
      "BucketKeyEnabled": true
    }]
  }'

# Bloquear acceso público
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Bucket configurado."
echo

# Generar backend.tf a partir del ejemplo
BACKEND_FILE="$TERRAFORM_DIR/backend.tf"
sed \
  -e "s|YOUR_TFSTATE_BUCKET_NAME|$BUCKET_NAME|g" \
  -e "s|YOUR_STATE_FILE_KEY|$STATE_KEY|g" \
  -e "s|us-east-1|$REGION|g" \
  "$TERRAFORM_DIR/backend.tf.example" > "$BACKEND_FILE"

echo "Generado: terraform/backend.tf"
echo
echo "Siguiente paso:"
echo "  cd terraform && terraform init"
