provider "aws" {
  region = "us-east-1"  # Change as needed
}

# Create IAM Role for Session Manager
resource "aws_iam_role" "ssm_role" {
  name = "example_ssm_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach AWS managed policy AmazonSSMManagedInstanceCore to the role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile for EC2
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "example_ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Security group allowing SSH access for testing (optional)
resource "aws_security_group" "sg" {
  name        = "example_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-0e6f0f139e00db2e3" # replace with your VPC ID

  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance resource
resource "aws_instance" "example" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-1, update for your region
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "ireland.pem"  # replace with your key pair name

  tags = {
    Name = "SSM-enabled-instance"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "instance_private_ip" {
  value = aws_instance.example.private_ip
}
