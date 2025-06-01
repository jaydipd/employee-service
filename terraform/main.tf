provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "employee-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0] # picks the first available AZ
  tags = {
    Name = "employee-public-subnet"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "employee-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "employee-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id
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
    Name = "employee-ecs-sg"
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "employee_table" {
  name           = "Employee"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Name = "employee-table"
  }
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "employee-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "employee-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.employee_table.arn
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "employee_cluster" {
  name = "employee-cluster"
}

# EC2 Instance for ECS
resource "aws_instance" "ecs_instance" {
  ami                    = "ami-0af9569868786b23a" # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.employee_cluster.name} >> /etc/ecs/ecs.config
yum update -y
yum install -y ecs-init
systemctl start ecs
systemctl enable ecs
EOF
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  tags = {
    Name = "employee-ecs-instance"
  }
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "employee-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "employee-ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "employee_task" {
  family                   = "employee-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "employee-container"
      image     = "145523123074.dkr.ecr.ap-south-1.amazonaws.com/employee-service:21"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      memory = 512
      cpu    = 256
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "employee_service" {
  name            = "employee-service"
  cluster         = aws_ecs_cluster.employee_cluster.id
  task_definition = aws_ecs_task_definition.employee_task.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}