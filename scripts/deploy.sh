#!/usr/bin/env bash
# Despliega la infraestructura completa.
# Uso: ./scripts/deploy.sh [--auto-approve]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$ROOT_DIR/terraform"
AUTO_APPROVE="${1:-}"

for cmd in terraform aws npm; do
  command -v "$cmd" >/dev/null || { echo "ERROR: '$cmd' no encontrado." >&2; exit 1; }
done

# Validar variables requeridas
if [ -z "${TF_VAR_rds_password:-}" ] && ! grep -q "rds_password" "$TERRAFORM_DIR/terraform.tfvars" 2>/dev/null; then
  echo "ERROR: rds_password no configurado. Usa: export TF_VAR_rds_password='tu-password'" >&2
  exit 1
fi

if [ -z "${TF_VAR_alert_email:-}" ] && ! grep -q "alert_email" "$TERRAFORM_DIR/terraform.tfvars" 2>/dev/null; then
  echo "WARN: alert_email no configurado — las alertas SNS no enviarán email."
fi

echo "==> Instalando dependencias de las Lambdas..."
for dir in insertStudentLambda getEmployeeImagesLambda seedDatabaseLambda; do
  echo "    npm install: lambda/$dir"
  (cd "$ROOT_DIR/lambda/$dir" && npm install --omit=dev --silent)
done

echo "==> terraform init..."
(cd "$TERRAFORM_DIR" && terraform init)

echo "==> terraform validate..."
(cd "$TERRAFORM_DIR" && terraform validate)

echo "==> terraform plan..."
(cd "$TERRAFORM_DIR" && terraform plan -out=tfplan)

if [ "$AUTO_APPROVE" = "--auto-approve" ]; then
  (cd "$TERRAFORM_DIR" && terraform apply tfplan)
else
  echo ""
  read -r -p "¿Aplicar el plan? (yes/no): " confirm
  [ "$confirm" = "yes" ] || { echo "Cancelado."; exit 0; }
  (cd "$TERRAFORM_DIR" && terraform apply tfplan)
fi

echo ""
echo "==> Deploy completado. Outputs:"
(cd "$TERRAFORM_DIR" && terraform output -json | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
for k, v in data.items():
    val = '<sensible>' if v.get('sensitive') else v.get('value', '')
    print(f'  {k} = {val}')
")

echo ""
echo "Pasos siguientes:"
echo "  ./scripts/seed-database.sh"
echo "  ./scripts/upload-images.sh ./imagenes"
