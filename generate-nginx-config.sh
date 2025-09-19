#!/bin/bash

# Script to generate nginx config with IP addresses instead of hostnames
# This fixes DNS resolution issues in some Docker environments

echo "Generating nginx config with container IP addresses..."

# Get container IP addresses
APP1_IP=$(docker compose exec app1 hostname -i | tr -d '\r')
APP2_IP=$(docker compose exec app2 hostname -i | tr -d '\r') 
APP3_IP=$(docker compose exec app3 hostname -i | tr -d '\r')
APP4_IP=$(docker compose exec app4 hostname -i | tr -d '\r')
APP5_IP=$(docker compose exec app5 hostname -i | tr -d '\r')

echo "Container IPs:"
echo "  app1: $APP1_IP"
echo "  app2: $APP2_IP"
echo "  app3: $APP3_IP"
echo "  app4: $APP4_IP"
echo "  app5: $APP5_IP"

# Generate nginx config with IP addresses
cat > nginx/nginx-with-ips.conf << EOF
events {
    worker_connections 1024;
}

http {
    # Define upstream backend servers using IP addresses
    upstream backend_servers {
        # Round-robin load balancing (default)
        server $APP1_IP:3000 max_fails=3 fail_timeout=30s;
        server $APP2_IP:3000 max_fails=3 fail_timeout=30s;
        server $APP3_IP:3000 max_fails=3 fail_timeout=30s;
        server $APP4_IP:3000 max_fails=3 fail_timeout=30s;
        server $APP5_IP:3000 max_fails=3 fail_timeout=30s;
    }

    # Server configuration
    server {
        listen 80;
        server_name localhost;

        # Access and error logs
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        # Main location - proxy to backend servers
        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            
            # Health check and timeout settings
            proxy_connect_timeout 5s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
            
            # Retry settings for failed backend connections
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 10s;
        }

        # Status endpoint for nginx
        location /nginx-status {
            stub_status on;
            access_log off;
        }

        # Health check endpoint
        location /health-check {
            return 200 "nginx is healthy\\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo "Generated nginx config with IPs: nginx/nginx-with-ips.conf"