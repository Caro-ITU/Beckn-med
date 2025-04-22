server {
    listen 80;
    listen [::]:80;
    server_name onix-gateway.domain_name.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name onix-gateway.domain_name.com;
    
    underscores_in_headers on;
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss application/javascript text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon font/woff font/woff2 application/octet-stream font/ttf;
    
    ssl_certificate /etc/letsencrypt/live/onix-gateway.domain_name.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/onix-gateway.domain_name.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    access_log /var/log/nginx/app_beckn_gateway_access.log;
    error_log /var/log/nginx/app_beckn_gateway_error.log;
    client_max_body_size 10M;
    keepalive_timeout 70;
    ignore_invalid_headers off;
    
    location / {
        if ($uri ~* "\.(jpg|jpeg|png|gif|ico|ttf|eot|svg|woff|woff2|css|js)$") {
            add_header 'Cache-Control' 'no-cache';
        }
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-URIScheme https;
        proxy_pass "http://localhost:4030/";
        
        set $cors '';
        if ($http_origin ~ '^https?://(localhost|onix\-gateway\.foodeez\.dk)') {
            set $cors 'true';
        }
        add_header 'Access-Control-Allow-Origin' "$http_origin" always;
        
        if ($cors = 'true') {
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With,Range,ApiKey,pub_key_format' always;
        }
        
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' "$http_origin" always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With,Range,ApiKey,pub_key_format' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }
    }
}
