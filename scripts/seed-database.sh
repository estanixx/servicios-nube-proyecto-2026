#!/usr/bin/env bash
# Invoca la Lambda seed-database para crear la tabla e insertar datos dummy.
# Debe correrse después de terraform apply.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$ROOT_DIR/terraform"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

for cmd in aws terraform; do
  command -v "$cmd" >/dev/null || { echo "ERROR: '$cmd' no encontrado." >&2; exit 1; }
done

FUNCTION_NAME="$(cd "$TERRAFORM_DIR" && terraform output -raw insert_student_lambda_name 2>/dev/null | sed 's/insert-student/seed-database/')"

if [ -z "$FUNCTION_NAME" ]; then
  echo "ERROR: No se pudo obtener el nombre de la función. ¿Corriste terraform apply?" >&2
  exit 1
fi

echo "==> Invocando $FUNCTION_NAME..."
OUT=$(mktemp)
aws lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --region "$REGION" \
  --log-type Tail \
  "$OUT" > /tmp/lambda-meta.json

echo "==> Respuesta:"
cat "$OUT"
echo ""

STATUS=$(python3 -c "import json; d=json.load(open('$OUT')); print(d.get('statusCode', 'N/A'))" 2>/dev/null || echo "N/A")
[ "$STATUS" = "200" ] && echo "Seed completado." || echo "WARN: statusCode=$STATUS — revisa los logs en CloudWatch."
rm -f "$OUT" /tmp/lambda-meta.json
