server {

        root /var/www/domain_name.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name domain_name.com www.domain_name.com;

        location / {
                try_files $uri $uri/ =404;
        }


}
server {
    if ($host = domain_name.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen 80;
        listen [::]:80;

        server_name domain_name.com www.domain_name.com;
    return 404; # managed by Certbot


}