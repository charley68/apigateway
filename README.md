URL Shortener (based on https://medium.com/@jeeri95/serverless-url-shortener-using-aws-97f1929c475e)



VEDANSH QUESTIONS
CREDENTIALS.  Locally i dont define any creds in my probvider and it takes them from ~/.aws/credentials

When i moved to Cloud, i added two environment variables in CLOUD called AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY


│ Warning: Value for undeclared variable
│ 
│ The root module does not declare a variable named "AWS_ACCESS_KEY_ID" but a
│ value was found in file
│ "/home/tfc-agent/.tfc-agent/component/terraform/runs/run-dAk59YoGUnZG2H5c/terraform.tfvars".
│ If you meant to use this value, add a "variable" block to the
│ configuration.
│ 
│ To silence these warnings, use TF_VAR_... environment variables to provide
│ certain "global" settings to all configurations in your organization. To
│ reduce the verbosity of these warnings, use the -compact-warnings option.



i updatd my lambda code but said nothing to apply (since no TF files changed). So i ran a tf taint on just the lambda assuming it would then 
update,  but then it said "ResourceConflictException: Function already exist: url-shortener-create2”.  I had to destroy and re-apply.

RESULTS:

SHORTENER2
===========

CREATE:    Via LAMBDA TEST using:
{
  "body": "{\"long_url\": \"this is a test\"}"
}

CREATE: VIA THE API GATEWAY TEST:
{"long_url": "this is another aaaa test”}

********************************

SHORT:  Via LAMBDA TEST using:
{
  "short_id": "bob"
}

b: VIA THE API GATEWAY TEST:
This fails with 
Endpoint response body before transformations: {"statusCode": 301, "location": "https://blog.thomasnet.com/hs-fs/hubfs/shutterstock_774749455.jpg?width=1200&name=shutterstock_774749455.jpg"}Execution failed due to configuration error: Malformed Lambda proxy response

The Diffrence between the manualyl create one that works and the one TF one that doesnt work is the INTEGRATION RESPONSE.  
FOr manual, it has Proxy False, for TF is has Proxy True. proxy true created by me setting the Integration Type to " “AWS_PROXY”.



what is. https://serverless.tf/
Have you used. IAM Policy Simulator ?
How to use the import block to pull existing AWS resources into TF
How to handle updating a value that isnt known until after creation causing cylcic error. Example, the lambda environment variable

