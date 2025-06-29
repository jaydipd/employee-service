resource "aws_ecs_cluster" "main" {
  name = "employee-cluster"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_launch_configuration" "ecs" {
  name_prefix          = "ecs-instance"
  image_id             = "ami-0dc2d3e4c0f9ebd18" # Amazon ECS-optimized AMI for your region
  instance_type        = "t3.medium"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance.name
  user_data            = file("ecs-user-data.sh")
  security_groups      = [aws_security_group.ecs_instances.id]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                      = "ecs-autoscaling-group"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.public1.id, aws_subnet.public2.id]
  launch_configuration      = aws_launch_configuration.ecs.name
  health_check_type         = "EC2"
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}
resource "aws_security_group" "ecs_instances" {
  name        = "ecs-instances-sg"
  description = "Allow ECS instance traffic"
  vpc_id      = var.vpc_id  # <-- Ensure this variable is defined or replace with actual VPC ID

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP or subnet in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-instance-sg"
  }
}
