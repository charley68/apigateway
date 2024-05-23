


data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "lambda/"
  output_path = "lambda/lambda.zip"
}

resource "aws_lambda_function" "url-shortener-retrieve2" {

    depends_on = [ aws_iam_role_policy_attachment.aws-lambda-policy ]
    filename                       = "${path.module}/lambda/lambda.zip"
    function_name                  = "url-shortener-retrieve2"
    role                           =  aws_iam_role.AWSAccessRole.arn
    handler                        = "url-shortener-retrieve2.lambda_handler"
    runtime                        = "python3.8"
}

resource "aws_lambda_function" "url-shortener-create2" {

    depends_on = [ aws_iam_role_policy_attachment.aws-lambda-policy ]
    filename                       = "${path.module}/lambda/lambda.zip"
    function_name                  = "url-shortener-create2"
    role                           =  aws_iam_role.AWSAccessRole.arn
    handler                        = "url-shortener-create2.lambda_handler"
    runtime                        = "python3.8"

# DONT KNOW HOW THIS IS POSSIBLE. I need to set an environemn variable on a LAMBDA
# function but the value isnt known until the api gateway is deployed
  #environment {
   # variables = {
   #  APP_URL =  aws_api_gateway_stage.dev-stage.invoke_url
   # }
 # }

}

# This is usually automatically added by AWS console to allow api gateway to execute Lambda functions
resource "aws_lambda_permission" "retrieve_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url-shortener-retrieve2.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.url-shortener-api.execution_arn}/*"
}

resource "aws_lambda_permission" "create_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url-shortener-create2.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.url-shortener-api.execution_arn}/*"
}