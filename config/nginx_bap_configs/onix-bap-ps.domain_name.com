server {
        server_name onix-bap-ps.domain_name.com;
        location / {
                # This for Host, Client and Forwarded For
                proxy_set_header Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

                # For Web Sockets.
                #proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";

                proxy_pass "http://localhost:5003";
        }

}

server {
    if ($host = onix-bap-ps.domain_name.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen 80;
        listen [::]:80;
        server_name onix-bap-ps.domain_name.com;
    return 404; # managed by Certbot
}
