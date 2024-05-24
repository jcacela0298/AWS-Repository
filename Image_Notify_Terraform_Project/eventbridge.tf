# Define EventBridge rule
resource "aws_cloudwatch_event_rule" "console" {
  name        = "ImageUploadRule"
  description = <<EOF
    When an image is uploaded to the S3 bucket, it should trigger this EventBridge rule.
    This rule should then activate a Lambda function to retrieve the uploaded image from S3, 
    utilize AWS Rekognition to extract labels from the image, and finally send an email notification 
    with image details via AWS SNS.
  EOF

# Define what activates the rule
event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["s3.amazonaws.com"],
      "eventName": ["PutObject"],
      "requestParameters": {
        "bucketName": ["image-upload-bucket-${random_string.bucket_suffix.result}"]
      }
    }
  })
}


# Specify the Lambda function as the rule's target
# The rule is taken from above, the target_id is just a relevent comment, and arn
# is dynamically referencing the Lambda function's ARN from lambda.tf and this ARN
# will be generated after terraform apply. 
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "ImageProcessingFunction"
  arn       = aws_lambda_function.test_lambda.arn 
}

# Ensure the target is created after the Lambda function so the arn will be able to 
# be retrieve (Maybe optional, Terraform might already understand dependency order)
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.console.arn
}