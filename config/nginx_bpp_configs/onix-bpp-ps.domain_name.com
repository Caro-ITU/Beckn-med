server {
        server_name onix-bpp-ps.domain_name.com;
        location / {
                proxy_pass "http://localhost:3009";
        }

}

server {
    if ($host = onix-bpp-ps.domain_name.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen 80;
        listen [::]:80;
        server_name onix-bpp-ps.domain_name.com;
    return 404; # managed by Certbot


}