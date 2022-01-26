resource "aws_lambda_function" "ssl-checker" {
  function_name = "ssl-cert-checker"

  filename = "ssl-checker.zip"
  source_code_hash = filebase64sha256("ssl-checker.zip")
  runtime = "python3.9"
  handler = "lambda_function.lambda_handler"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "ssl-checker" {
  name = "/aws/lambda/${aws_lambda_function.ssl-checker.function_name}"
  retention_in_days = 30
}
  
  
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# API GATEWAY CONFIGURATIONS

resource "aws_apigatewayv2_api" "lambda" {
  name          = "ssl-checker-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id
  name        = "ssl_checker_stage"
  auto_deploy = true
  
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

}


resource "aws_apigatewayv2_integration" "ssl-checker" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.ssl-checker.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "ssl-checker" {
  api_id = aws_apigatewayv2_api.lambda.id
  route_key = "GET /ssl-checker"
  target    = "integrations/${aws_apigatewayv2_integration.ssl-checker.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ssl-checker.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

