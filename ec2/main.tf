provider "aws" {
    region = "us-east-1"
}

# creacion grupo de seguridad
resource "aws_security_group" "basic_web_server_sgr"{
    name = "basic_web_server_sgr"
    description = "Allow SSH, HTTP, and ICMP traffic for a basic web server"

    #Allow SSH (Port 22)
    ingress{
        from_port   =   22
        to_port     =   22
        protocol    =   "tcp"
        cidr_blocks  =   ["0.0.0.0/0"]
    }

    #Allow HTTP (port 80)
    ingress {
        from_port   =   80
        to_port     =   80
        protocol    =   "tcp"
        cidr_blocks =   ["0.0.0.0/0"]
    }

    #Allow all outbound traffic
    egress{
        from_port   =   0
        to_port     =   0
        protocol    =   "-1"
        cidr_blocks =   ["0.0.0.0/0"]
    }
    tags = {
        Name = "BasicWebServerSecurityGroup"
    }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
   owners = ["099720109477"]
  
}

#Create an EC2 instance and associate it with the security group
resource "aws_instance" "basic_web_server"{
    availability_zone   = "us-east-1a"
    ami                 = data.aws_ami.ubuntu.id
    instance_type       = "t2.micro"
    vpc_security_group_ids = [aws_security_group.basic_web_server_sgr.id]
    key_name            = "pin"
    user_data = "${file("install_soft.sh")}"
    security_groups     = [aws_security_group.basic_web_server_sgr.name]
    
    tags = {
        Name = "BasicWebServerInstance"
    }
}

#Output the public DNS name for SSH access
output "intance_public_dns" {
    value               = aws_instance.basic_web_server.public_dns
}

#Output the public IP for SSH access
output "intance_public_ip" {
    value = aws_instance.basic_web_server.public_ip
}