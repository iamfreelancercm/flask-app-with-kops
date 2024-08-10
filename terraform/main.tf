provider "aws" {
  region = "us-east-1"
}

# Define a security group that allows SSH access
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh-"
  description = "Allow SSH access from anywhere"

  # Allow inbound traffic on port 22 (SSH) from any IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags to help identify the security group
  tags = {
    Name = "allow-ssh-sg"
  }
}

# Define the EC2 instance resource
resource "aws_instance" "ready-to-go-ec2" {
  ami           = "ami-04a81a99f5ec58529"  # Replace with a valid AMI ID for your region
  instance_type = "t2.medium"                # Choose an appropriate instance type

  # Associate the security group with the EC2 instance
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # User data script to install awscli, kubectl, kops, and helm
  user_data = <<-EOF
              #!/bin/bash
              # Update the package index
              sudo apt update

              # Install prerequisites
              sudo apt install -y curl unzip

              # Install AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

              # Install kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

              # Install kops
              curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
              chmod +x kops
              sudo mv kops /usr/local/bin/kops

              # Install helm
              curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
              chmod 700 get_helm.sh
              ./get_helm.sh
              EOF


  # Tags to help identify the instance
  tags = {
    Name = "ready-to-go-ec2"
    AWSCli = "True"
    KubeCTL = "True"
    kOps = "True"
    Helm = "True"
  }

  # Optional: Add a key pair for SSH access
  # key_name = "test"  # Replace with your EC2 key pair name if needed
}

# Define an output to show the instance public IP
output "instance_public_ip" {
  value = aws_instance.ready-to-go-ec2.public_ip
}
