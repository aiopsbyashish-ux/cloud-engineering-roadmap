# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "local_vpc" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab16-vpc"
  }
}


# ============================================================
# PUBLIC SUBNETS
# ============================================================

resource "aws_subnet" "public_az_a" {
  vpc_id            = aws_vpc.local_vpc.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "public-az-a"
  }
}

resource "aws_subnet" "public_az_b" {
  vpc_id            = aws_vpc.local_vpc.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "public-az-b"
  }
}


# ============================================================
# PRIVATE SUBNETS
# ============================================================

resource "aws_subnet" "private_az_a" {
  vpc_id            = aws_vpc.local_vpc.id
  cidr_block        = "10.2.11.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "private-az-a"
  }
}

resource "aws_subnet" "private_az_b" {
  vpc_id            = aws_vpc.local_vpc.id
  cidr_block        = "10.2.12.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "private-az-b"
  }
}


# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.local_vpc.id

  tags = {
    Name = "lab16-igw"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.local_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE ASSOCIATIONS
# ============================================================

resource "aws_route_table_association" "public_az_a" {
  subnet_id      = aws_subnet.public_az_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_az_b" {
  subnet_id      = aws_subnet.public_az_b.id
  route_table_id = aws_route_table.public_rt.id
}


# ============================================================
# ELASTIC IP FOR NAT GATEWAY
# ============================================================

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "lab16-nat-eip"
  }
}


# ============================================================
# NAT GATEWAY
# ============================================================

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_az_a.id

  tags = {
    Name = "lab16-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}


# ============================================================
# PRIVATE ROUTE TABLE
# ============================================================

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.local_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}


# ============================================================
# PRIVATE ROUTE TABLE ASSOCIATIONS
# ============================================================

resource "aws_route_table_association" "private_az_a" {
  subnet_id      = aws_subnet.private_az_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_az_b" {
  subnet_id      = aws_subnet.private_az_b.id
  route_table_id = aws_route_table.private_rt.id
}

# ============================================================
# S3 GATEWAY VPC ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.local_vpc.id
  service_name      = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_rt.id
  ]

  tags = {
    Name = "lab16-s3-endpoint"
  }
}

# ============================================================
# PRIVATE EC2 SECURITY GROUP
# ============================================================

resource "aws_security_group" "test_ec2_sg" {
  name        = "lab16-private-ec2-sg"
  description = "Security group for private EC2 validation instance"
  vpc_id      = aws_vpc.local_vpc.id

  # No inbound rules.
  # We will manage the instance through AWS Systems Manager.

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab16-private-ec2-sg"
  }
}


# ============================================================
# IAM ROLE FOR PRIVATE EC2
# ============================================================

resource "aws_iam_role" "test_ec2_role" {
  name = "lab16-private-ec2-role"

  # Trust policy - allows EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "lab16-private-ec2-role"
  }
}


# ============================================================
# SSM POLICY ATTACHMENT
# ============================================================

resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.test_ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ============================================================
# EC2 INSTANCE PROFILE
# ============================================================

resource "aws_iam_instance_profile" "test_ec2_profile" {
  name = "lab16-private-ec2-profile"
  role = aws_iam_role.test_ec2_role.name
}


# ============================================================
# AMAZON LINUX 2023 AMI LOOKUP
# ============================================================

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# ============================================================
# PRIVATE EC2 VALIDATION INSTANCE
# ============================================================

resource "aws_instance" "private_test" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = "t3.micro"

  subnet_id = aws_subnet.private_az_a.id

  # Deliberately keep this instance private
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.test_ec2_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.test_ec2_profile.name

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "lab16-private-test"
  }
}
# ============================================================
# S3 GATEWAY ENDPOINT VALIDATION
# ============================================================

# ------------------------------------------------------------
# 1. Dedicated S3 bucket for this validation
# ------------------------------------------------------------

resource "aws_s3_bucket" "validation" {
  bucket = "lab16-s3-validation-400131408529"

  tags = {
    Name = "lab16-s3-validation"
  }
}


# ------------------------------------------------------------
# 2. Create a test object inside the bucket
# ------------------------------------------------------------

resource "aws_s3_object" "validation" {
  bucket = aws_s3_bucket.validation.id

  key     = "validation.txt"
  content = "Lab 16 - S3 Gateway Endpoint validation successful."
}


# ------------------------------------------------------------
# 3. Give our existing EC2 IAM role permission
#    to read ONLY validation.txt
# ------------------------------------------------------------

resource "aws_iam_role_policy" "s3_validation" {
  name = "lab16-s3-validation-policy"

  role = aws_iam_role.test_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.validation.arn}/validation.txt"
        ]
      }
    ]
  })
}