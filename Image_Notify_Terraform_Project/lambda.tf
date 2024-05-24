# Package the Lambda function code (assuming lambda1.py is in the same directory)
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda1.py"
  output_path = "lambda_function_payload.zip"
}


# Create the Lambda function
resource "aws_lambda_function" "test_lambda" {
  filename = "${data.archive_file.lambda.output_path}"
  function_name    = "ImageNotify"
  handler          = "lambda1.lambda_handler"  # Make sure it is lambda1 which is the same as the python file
  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = "PUT YOUR ARN HERE"  # Replace with the ARN of your existing IAM role
  runtime          = "python3.8"


  # Here we need to dynamically pass the SNS Topic ARN to Lambda
  # (Wondering if this should be in the lambda.tf file or if it should
  # Go into the sns.tf file for better modularization.) 
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.my_topic.arn
    }
  }
}