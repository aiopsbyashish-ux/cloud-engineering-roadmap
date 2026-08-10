#!/bin/bash

dnf install -y httpd
systemctl enable --now httpd

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body>
<h1>Hello from the Custom VPC Lab!</h1>
<p>This EC2 instance is running inside a Terraform-created VPC.</p>
</body>
</html>
EOF