# Resource to create a globally unique SNS topic name suffix
resource "random_string" "sns_topic_suffix" {
  length  = 8
  special = false
}


# Define the SNS topic 
resource "aws_sns_topic" "my_topic" {
  name = "ImageNotification-${random_string.sns_topic_suffix.result}"
}


# Define the Topic Subscription
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "email"
  endpoint  = "example@gmail.com" # Put your email address here
  endpoint_auto_confirms = true # This doesn't work for the email endpoint, customer needs to manually confirm
}