# Get the latest Amazon Linux 2023 AMI from AWS Systems Manager Parameter Store
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# Launch Template
# Defines HOW each EC2 instance created by the ASG should look
resource "aws_launch_template" "app" {
  name_prefix   = "lab17-app-"
  image_id      = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = "t3.micro"

  # Application EC2 security group
  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  # Bootstrap the web server automatically when EC2 starts
  user_data = base64encode(<<-EOF
    #!/bin/bash

    dnf install -y nginx

    systemctl enable nginx

    cat > /usr/share/nginx/html/index.html <<HTML
    <html>
      <body>
        <h1>Lab 17 - ALB + ASG</h1>
        <p>Server: $(hostname)</p>
      </body>
    </html>
    HTML

    systemctl start nginx
  EOF
  )

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Tags applied to EC2 instances launched from this template
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "lab17-app-server"
    }
  }
}


# Auto Scaling Group
# Defines HOW MANY EC2 instances should run and WHERE
resource "aws_autoscaling_group" "app" {
  name = "lab17-app-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  # EC2 instances will be distributed across private subnets/AZs
  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  # Automatically register ASG instances with the ALB Target Group
  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  # Use load balancer health checks for ASG instance health
  health_check_type         = "ELB"
  health_check_grace_period = 120

  # ASG uses this template when creating EC2 instances
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}