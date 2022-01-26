# Solution

## About
This repository contains the proof of concept for "Project Purple Cow", a tool which would allow users to monitor the validity of their ssl certificates for their domains. 

This repository contains a terraform script which when run will deploy an infrastructure with the main components/services
  1. **Lambda function** that contains the python code to check for ssl certificate validity according to certificate expiration date. if valid it returns an HTTP response with the message citing the domain's validity and it's expiration date
  2.  **API Gateway** contains an api that serves to invoke the above lambda function upon hitting the aws generated url and endpoint


## How to Run ssl-checker on Terraform

you can run the terraform script by cloning the repository and running it locally

### Run Locally

**Make sure you have the following tools installed locally before running the terraform script**
  - Terraform CLI (which can be found here: https://www.terraform.io/downloads)
  - AWS CLI (this is somewhat *optional*, but is a good way to test the lambda function by invoking it through the cli)
  - *Note*: make sure you have an aws access key and secret access key with links to a user with permissions to create iam-roles, lambda functions, cloudwatch logs, and api-gateway APIs
  

The following are steps to run the terraform script locally
  1. clone the repository to your local computer
  2. run "terraform init" in the root directory where the "main.tf" file is located
  3. run "terraform plan" to view the resources to be created in your AWS 
  4. run "terraform apply" to apply those resources to your AWS
  

### How to use 
Once the terraform script has been successfully executed locally, you can test the lambda function and it's api-gateway trigger

Through the AWS console:
  1. Login to your AWS console
  2. Go to AWS lambda service page
  3. Find the function named "ssl-cert-checker" and open it
  4. Click on either the "API Gateway" box under the "Function Overview" window or click the "Configuration" tab
  5. Click on the "API endpoint" link to open in browser
  6. add "/ssl-checker" to the end of the endpoint to view the http response 
  
  

## Future Updates and considerations

### Possible future features
  - Return the amount of days left before certificate expiry 
  - use cloudwatch to trigger the lambda function everyday 
  - Use AWS SNS to automatically notify when a certificate is 30 days, 15 days, 3 days, and/or 1 day away from expiring 
  - Utilize automated SSL renewal tools such as "Certbot" to automatically renew the SSL certificate when it is number of days away from expiring. this can be integrated with AWS Lambda.

### Considerations
  - Currently there will need to be a new lambda function for each domain, although we can modify it to accept multiple domains it could get in the way of using certbot to automate the SSL renewal, especially if all domains don't use the same Certificate Authority.
 


 