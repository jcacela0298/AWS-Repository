import json     # To handle JSON data
import boto3    # To interact with AWS services such as Rekognition
import os       # Allows retrieval of the dynamic SNS topic ARN from environment variable


# Lambda Handler takes two parameters, event and context, which contains
# The event that activated the function and the runtime environment 
def lambda_handler(event, context): 
    
    # Extract the bucket name and object key from the event parameter
    print(event) 
    bucket_name = event["detail"]["requestParameters"]["bucketName"]
    object_key = event["detail"]["requestParameters"]["key"]
    
    # Initialize the S3, Rekognition, and SNS clients
    s3_client = boto3.client('s3')
    rekognition_client = boto3.client('rekognition')
    sns_client = boto3.client('sns')
    
    # Rekognition already retrieves the uploaded image from S3, so this part here is commented out:
    # response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    # image_data = response['Body'].read()
    
    # Process the image with AWS Rekognition
    rekognition_response = rekognition_client.detect_labels(Image={'S3Object':{'Bucket':bucket_name, 'Name':object_key}})
    
    # Extract labels detected by Rekognition
    labels = [label['Name'] for label in rekognition_response['Labels']]
    
    # Retrieve SNS Topic ARN from environment variable specified in the lambda.tf file
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    # Trigger email notification via AWS SNS, using the retrieved SNS Topic ARN
    sns_client.publish(
        TopicArn=sns_topic_arn,
        Subject='Image Analysis Results',
        Message=json.dumps({'Image': object_key, 'Labels': labels})
    )
    
    # Return a success response
    return {
        'statusCode': 200,
        'body': json.dumps('Image analysis completed successfully!')
    }