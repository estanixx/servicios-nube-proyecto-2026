#!/usr/bin/env bash
# Monitorea en tiempo real las instancias del ASG y las alarmas de CloudWatch.
# Usar durante la prueba de stress para ver el auto scaling en acción.
# Uso: ./scripts/monitor-asg.sh
set -euo pipefail

ASG_NAME="nexacloud-asg"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
INTERVAL=5

clear
echo "Monitoreando ASG: $ASG_NAME — actualizando cada ${INTERVAL}s (Ctrl+C para salir)"
echo "=================================================================="

while true; do
  TIMESTAMP=$(date '+%H:%M:%S')

  # Instancias activas
  INSTANCES=$(aws autoscaling describe-auto-scaling-instances \
    --region "$REGION" \
    --query "AutoScalingInstances[?AutoScalingGroupName=='$ASG_NAME'].{ID:InstanceId,State:LifecycleState,Health:HealthStatus}" \
    --output table 2>/dev/null)

  # CPU promedio del ASG (último minuto)
  CPU=$(aws cloudwatch get-metric-statistics \
    --region "$REGION" \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=AutoScalingGroupName,Value="$ASG_NAME" \
    --start-time "$(date -u -d '2 minutes ago' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v-2M '+%Y-%m-%dT%H:%M:%SZ')" \
    --end-time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --period 60 \
    --statistics Average \
    --query "Datapoints[-1].Average" \
    --output text 2>/dev/null)

  # Estado de la alarma de scale-up
  ALARM=$(aws cloudwatch describe-alarms \
    --alarm-names "nexacloud-cpu-high" \
    --region "$REGION" \
    --query "MetricAlarms[0].StateValue" \
    --output text 2>/dev/null)

  # Última actividad del ASG
  LAST_ACTIVITY=$(aws autoscaling describe-scaling-activities \
    --auto-scaling-group-name "$ASG_NAME" \
    --region "$REGION" \
    --max-items 1 \
    --query "Activities[0].{Causa:Cause,Estado:StatusCode}" \
    --output table 2>/dev/null)

  clear
  echo "=== NexaCloud ASG Monitor — $TIMESTAMP ==="
  echo ""
  echo "CPU promedio: ${CPU}%"
  echo "Alarma cpu-high: $ALARM"
  echo ""
  echo "Instancias:"
  echo "$INSTANCES"
  echo ""
  echo "Última actividad de scaling:"
  echo "$LAST_ACTIVITY"

  sleep "$INTERVAL"
done
