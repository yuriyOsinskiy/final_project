terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_security_group" "https_http_ssh" {
  name        = "allow_four_ports"
  description = "Allow HTTPS HTTP SSH and 8080 inbound traffic"
  vpc_id      = "vpc-0df93e96a5fba6b2b"

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "8080 from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_four_ports"
  }
}

resource "aws_instance" "myjenkinsserver" {
  ami = "ami-0d1ddd83282187d18"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.https_http_ssh.id]
  associate_public_ip_address = true
  key_name = "osinskyi"
  tags = {"Name"="jenkins_server"}
}

resource "aws_instance" "webserver1" {
  ami = "ami-0d1ddd83282187d18"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.https_http_ssh.id]
  availability_zone = "eu-central-1a"
  associate_public_ip_address = true
  key_name = "osinskyi"
  user_data = <<EOF
#!/usr/bin/env bash
apt install -y apache2
systemctl enable apache2
echo "<html><body bgcolor=gray><center><h1><font color=red>WEBserver-1</h1></center></body></html>" > /var/www/html/index.html
systemctl start apache2
chown -R ubuntu:ubuntu /var/www/html
EOF
  tags = {"Name"="web_server_1"}
}

resource "aws_instance" "webserver2" {
  ami = "ami-0d1ddd83282187d18"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.https_http_ssh.id]
  availability_zone = "eu-central-1b"
  associate_public_ip_address = true
  key_name = "osinskyi"
  user_data = <<EOF
#!/usr/bin/env bash
apt install -y apache2
systemctl enable apache2
echo "<html><body bgcolor=gray><center><h1><font color=red>WEBserver-2</h1></center></body></html>" > /var/www/html/index.html
systemctl start apache2
chown -R ubuntu:ubuntu /var/www/html
EOF
  tags = {"Name"="web_server_2"}
}

resource "aws_elb" "elbwebserver" {
  name               = "elbwebserver"
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  security_groups = [ aws_security_group.https_http_ssh.id ]

 listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }
  instances                   = [aws_instance.webserver1.id, aws_instance.webserver2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "elb-for-webservers"
  }
}
output "public_ip_jenkins" {
  value = aws_instance.myjenkinsserver.public_ip
}

output "elb_dns_name" {
  value = aws_elb.elbwebserver.dns_name
}

output "public_ip_web1" {
  value = aws_instance.webserver1.public_ip
}

output "public_ip_web2" {
  value = aws_instance.webserver2.public_ip
}
