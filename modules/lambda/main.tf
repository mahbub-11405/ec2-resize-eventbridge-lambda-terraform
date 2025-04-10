
resource "aws_iam_role" "lambda_exec_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_exec_role_policy" {
  name = "ec2_resize_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "resize" {
  filename         = "${path.module}/lambda.zip"
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  timeout          = 120

  environment {
    variables = {
      INSTANCE_ID = var.instance_id
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_exec_role_policy,
    aws_iam_role_policy_attachment.attach_policy
  ]
}

output "lambda_arn" {
  value = aws_lambda_function.resize.arn
}

output "lambda_name" {
  value = aws_lambda_function.resize.function_name
}
