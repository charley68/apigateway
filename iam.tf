resource "aws_iam_policy" "dynamo-policy" {
  name        = "lambda-dynamodb-url-shortener2"
  description = "Allow acces to DyanmoDB"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/url-shortener-table"
        }
    ]
}
EOT
  tags = local.tags
}

resource "aws_iam_role" "AWSAccessRole" {
  name = "lambda-dynamodb-url-shortener-role2"

  # Enable the role to get AWS credentials
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["apigateway.amazonaws.com",
                    "lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "aws-lambda-policy" {
  role       = aws_iam_role.AWSAccessRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "aws-dynamo-policy" {
  role       = aws_iam_role.AWSAccessRole.name
  policy_arn = aws_iam_policy.dynamo-policy.arn
}


data "aws_caller_identity" "current" {}