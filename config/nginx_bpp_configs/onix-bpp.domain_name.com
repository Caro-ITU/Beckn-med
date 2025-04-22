server {
                # Put the server name as website name <website-name>.
        server_name onix-bpp.domain_name.com;

                location / {
                        # This for Host, Client and Forwarded For
                        proxy_set_header Host $http_host;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

                        # For Web Sockets.
                        #proxy_http_version 1.1;
                        proxy_set_header Upgrade $http_upgrade;
                        proxy_set_header Connection "upgrade";

                        # For Proxy.
                        proxy_pass "http://127.0.0.1:6002";
                }

}
server {
    if ($host = onix-bpp.domain_name.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen 80;
        listen [::]:80;
        server_name onix-bpp.domain_name.com;
    return 404; # managed by Certbot

}