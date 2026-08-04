#!/bin/bash

# Update packages
dnf update -y

# Install Apache Web Server
dnf install -y httpd

# Start Apache
systemctl start httpd

# Enable Apache to start on boot
systemctl enable httpd

# Create a simple web page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Terraform EC2 Lab</title>
</head>
<body>
    <h1>Hello from Terraform!</h1>
    <p>This EC2 instance was created automatically using Terraform.</p>
    <p>Welcome to your Cloud Engineering journey.</p>
</body>
</html>
EOF