#!/usr/bin/env bash
# Sube imágenes al bucket S3 de la infraestructura.
# Uso: ./scripts/upload-images.sh <directorio-de-imagenes>
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$ROOT_DIR/terraform"
IMAGES_DIR="${1:-$ROOT_DIR/imagenes}"

for cmd in aws terraform; do
  command -v "$cmd" >/dev/null || { echo "ERROR: '$cmd' no encontrado." >&2; exit 1; }
done

if [ ! -d "$IMAGES_DIR" ]; then
  echo "ERROR: Directorio de imágenes no encontrado: $IMAGES_DIR" >&2
  echo "Uso: $0 <directorio-de-imagenes>" >&2
  exit 1
fi

BUCKET="$(cd "$TERRAFORM_DIR" && terraform output -raw employee_images_bucket_name 2>/dev/null)"

if [ -z "$BUCKET" ]; then
  echo "ERROR: No se pudo obtener el nombre del bucket. ¿Corriste terraform apply?" >&2
  exit 1
fi

echo "==> Subiendo imágenes de '$IMAGES_DIR' a s3://$BUCKET/employee-images/..."
aws s3 cp "$IMAGES_DIR" "s3://$BUCKET/employee-images/" --recursive

COUNT=$(aws s3 ls "s3://$BUCKET/employee-images/" --recursive | wc -l | tr -d ' ')
echo "==> $COUNT archivo(s) en el bucket."
