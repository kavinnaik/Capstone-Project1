#!/bin/bash

yum update -y
yum install -y httpd

systemctl enable httpd
systemctl start httpd

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Project 1</title>
</head>
<body style="font-family: Arial; text-align:center; margin-top:80px;">
    <h1>Terraform Web Server Successfully Deployed!</h1>
    <h2>Capstone Project 1</h2>
    <p>Created by Kavin Naik</p>
    <p>Region: eu-west-1</p>
</body>
</html>
EOF
 