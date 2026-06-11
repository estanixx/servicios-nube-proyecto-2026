#!/bin/bash
set -e

dnf update -y
dnf install -y nginx

# Cambiar puerto SSH a 2222 (requerido por security group)
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
systemctl restart sshd

# Get instance ID from IMDS
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unknown")

# Create nginx config that injects X-Server-ID header dynamically on EVERY response
cat > /etc/nginx/conf.d/server-id.conf <<'NGINX'
server {
    listen 80;
    
    # Inject X-Server-ID header dynamically on every response
    add_header X-Server-ID $hostname always;
    
    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
NGINX

# Create a simple index page (server ID comes from header, not body)
cat > /usr/share/nginx/html/index.html <<HTML
<!DOCTYPE html>
<html>
<head>
    <title>NexaCloud</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>NexaCloud Intranet</h1>
    <p>Welcome to the NexaCloud internal portal.</p>
    <p>Server ID is sent in the X-Server-ID response header.</p>
</body>
</html>
HTML

systemctl start nginx
systemctl enable nginx