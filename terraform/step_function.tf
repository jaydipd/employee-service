# Step Function IAM Role
resource "aws_iam_role" "step_function_role" {
  name = "step_function_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

# Allow Step Function to invoke Lambda
resource "aws_iam_role_policy" "step_function_policy" {
  name = "step_function_policy"
  role = aws_iam_role.step_function_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ]
      Resource = aws_lambda_function.employee_processor.arn
    }]
  })
}

data "local_file" "state_machine_def" {
  filename = "${path.module}/employee_step_function_definition.json"
}
# Step Function state machine
module "step_function_employee" {
  source   = "git::https://github.com/jaydipd/step-function-module.git?ref=master"
  name     = "EmployeeWorkflow"
  role_arn = aws_iam_role.step_function_role.arn
  definition = data.local_file.state_machine_def.content
}