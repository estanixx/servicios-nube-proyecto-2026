#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/nexacloud-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Swap de 1GB para evitar OOM durante npm build en t3.micro
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

dnf update -y
dnf install -y nodejs npm nginx git stress
sudo dnf install postgresql15 -y

# Cambiar puerto SSH a 2222 (requerido por security group)
echo "Hola"
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
systemctl restart sshd
# Instance ID para header X-Server-ID
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id || hostname)

# Nginx arranca primero para que los health checks pasen mientras se hace el build
cat > /etc/nginx/conf.d/nexacloud.conf <<NGINX
server {
    listen 80 default_server;
    server_name _;

    add_header X-Server-ID "$INSTANCE_ID" always;

    location /health {
        access_log off;
        return 200 'OK';
        add_header Content-Type text/plain;
    }

    location /whoami {
        default_type text/html;
        return 200 '<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>NexaCloud - Servidor</title>
<style>body{font-family:Arial,sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f0f4f8;}
.card{background:white;padding:2rem 3rem;border-radius:12px;box-shadow:0 4px 20px rgba(0,0,0,0.1);text-align:center;}
h1{color:#2d3748;margin-bottom:0.5rem;}
.server-id{font-size:1.5rem;font-weight:bold;color:#3182ce;background:#ebf8ff;padding:0.5rem 1rem;border-radius:8px;margin-top:1rem;}</style>
</head>
<body><div class="card">
<h1>NexaCloud Intranet</h1>
<p>Este contenido es servido por:</p>
<div class="server-id">$INSTANCE_ID</div>
</div></body></html>';
    }

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
NGINX

rm -f /etc/nginx/conf.d/default.conf
systemctl enable nginx
systemctl start nginx

# Clonar repo y hacer build
APP_DIR=/opt/nexacloud
rm -rf "$APP_DIR"
git clone "${app_repo_url}" "$APP_DIR"
cd "$APP_DIR"
npm ci

cat > "$APP_DIR/.env.production" <<ENV
COMPANY_NAME=${company_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_HOST=${db_host}
DB_DATABASE=${db_database}
AWS_S3_LAMBDA_URL=${s3_lambda_url}
AWS_S3_LAMBDA_APIKEY=${api_key}
AWS_DB_LAMBDA_URL=${db_lambda_url}
AWS_DB_LAMBDA_APIKEY=${api_key}
STRESS_PATH=/usr/bin/stress
LOAD_BALANCER_URL=${load_balancer_url}
ENV

NODE_OPTIONS="--max_old_space_size=512" npm run build

# Systemd service para Next.js
cat > /etc/systemd/system/nexacloud.service <<'SERVICE'
[Unit]
Description=NexaCloud Next.js
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/nexacloud
Environment=PORT=3000
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
StandardOutput=append:/var/log/nexacloud-app.log
StandardError=append:/var/log/nexacloud-app.log

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable nexacloud
systemctl start nexacloud
