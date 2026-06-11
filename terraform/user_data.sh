#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/nexacloud-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

dnf update -y
dnf install -y nodejs npm nginx git

# Instance ID for X-Server-ID header
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id || hostname)

# Clone and build app
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

npm run build

# Systemd service
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

# Nginx reverse proxy
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
systemctl daemon-reload
systemctl enable nexacloud nginx
systemctl start nexacloud
systemctl start nginx
