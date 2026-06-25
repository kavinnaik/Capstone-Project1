#!/bin/bash

apt-get update -y
apt-get install apache2 -y

systemctl enable apache2
systemctl start  apache2

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Project 1</title>
</head>
<body>
    <h1>Project 1 - Terraform Web Server</h1>
    <p>This Apache web server was deployed using Terraform on Ubuntu.</p>
</body>
</html>
EOF
 
