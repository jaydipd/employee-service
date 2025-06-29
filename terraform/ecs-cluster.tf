resource "aws_ecs_cluster" "main" {
  name = "employee-cluster"
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
