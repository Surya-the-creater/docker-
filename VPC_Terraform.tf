provider "aws" {
  region = "ap-south-1" # Mumbai region
}

# 1. VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myvpc"
  }
}

# 2. Public Subnet
resource "aws_subnet" "mysub" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "mysub"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "mygw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mygw"
  }
}

# 4. Route Table
resource "aws_route_table" "myroot" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myroot"
  }
}

# 5. Route to Internet
resource "aws_route" "sl-route" {
  route_table_id         = aws_route_table.myroot.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mygw.id
}

# 6. Associate Subnet with Route Table
resource "aws_route_table_association" "subnet_assoc" {
  subnet_id      = aws_subnet.mysub.id
  route_table_id = aws_route_table.myroot.id
}

# 7. Security Group
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow HTTP and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysg"
  }
}

# 8. Get Latest Amazon Linux 2 AMI
data "aws_ami" "myami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# 9. EC2 Instance in Public Subnet
resource "aws_instance" "example" {
  ami                    = data.aws_ami.myami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.mysub.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name               = "aws01" # Replace with your actual key pair name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Terraform!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "VPC instance"
  }
}
