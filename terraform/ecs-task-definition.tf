resource "aws_ecs_task_definition" "employee_service" {
  family                   = "employee-service"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "employee-service"
      image     = "${var.ecr_registry}/${var.repo_name}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}
