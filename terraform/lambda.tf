# Lambda IAM Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic execution policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "employee_processor" {
  filename         = "employee-lambda.zip"
  function_name    = "EmployeeProcessorLambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "employee.lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("employee-lambda.zip")
}
