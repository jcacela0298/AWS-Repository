This workflow can automatically provision the necessary resources in order to receive an email with image characteristics after uploading an image into an S3 bucket.





Resources that will be automatically provisioned:

An S3 bucket with the following features:
	Globally unique name
	Versioning 
	Tags
	SSE-S3 encryption & bucket key enabled
	EventBridge compatibility turned on

An EventBridge rule with the following features:
	Event pattern for "PUT" events
	Lambda function as the target of the rule
	
An SNS Topic with the following features:
	Globally unique name
	Topic Subscription to the email endpoint
	
A Lambda function that:
	Gathers the event information
	Engages with S3, Rekognition, and SNS to gather the images,                        
        processes them, and send the information to the endpoint






What you need from the customer:


The ARN of the execution role for the Lambda function to work properly (this ARN goes into the lambda.tf file), making sure the role has at most the following permissions: 

	AmazonRekognitionFullAccess
	AmazonS3FullAccess
	AmazonSNSFullAccess
	AWSLambda_FullAccess
	AWSLambdaBasicExecutionRole
	CloudWatchEventsFullAccess
	CloudWatchLogsFullAccess

The email address to which the image details will be sent (this email address goes into the sns.tf file), along with having the customer manually accept the SNS Topic Subscription confirmation email sent to that email address immediately after deployment of this workflow and before any image upload.

The region, access key and secret access key for the account (this information goes into the main.tf file)






Once each of these requirements is met, on a Windows computer, open the command prompt, navigate to the directory with the files, and run the following command:

	terraform init

This will download the necessary Terraform files into the directory. Then, run the following command to see an overview of what should be deployed:

	terraform plan

This should show that 11 actions are to be added. Then, enter the following command to deploy the changes:
	terraform apply




Once this is done, the customer should again navigate to their email and confirm the SNS subscription. Once they do this, then an image can be uploaded into the newly generated bucket and an email should be sent with the image details.
	
