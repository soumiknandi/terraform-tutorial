#!/bin/bash
# Update system and install NGINX
# apt update -y
apt install nginx -y

# Start and enable NGINX
systemctl start nginx
systemctl enable nginx

# Create a simple webpage
echo "<h1>Welcome to My NGINX Web Server on AWS!</h1>" > /var/www/html/index.html

# Restart NGINX to apply changes
systemctl restart nginx
