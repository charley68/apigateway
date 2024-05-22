


data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "lambda/"
  output_path = "lambda/lambda.zip"
}

resource "aws_lambda_function" "url-shortener-retrieve" {

    depends_on = [ aws_iam_role_policy_attachment.aws-lambda-policy ]
    filename                       = "${path.module}/lambda/lambda.zip"
    function_name                  = "url-shortener-retrieve2"
    role                           =  aws_iam_role.AWSAccessRole.arn
    handler                        = "url-shortener-retrieve2.lambda_handler"
    runtime                        = "python3.8"


}