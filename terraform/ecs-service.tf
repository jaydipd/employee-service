resource "aws_ecs_service" "employee" {
  name            = "employee-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.employee_service.arn
  launch_type     = "EC2"
  desired_count   = 1

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [aws_autoscaling_group.ecs]
}
