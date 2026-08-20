#!/bin/bash

dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body>
<h1>Hello from the EC2 Module!</h1>
<p>This web server was configured automatically using Terraform user data.</p>
</body>
</html>
EOF