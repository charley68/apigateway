URL Shortener (based on https://medium.com/@jeeri95/serverless-url-shortener-using-aws-97f1929c475e)

Steps:

Create DYNAMODB Table 
Cream IAM Policy
Create IAM Role
Attatch AWSLambdaBasicExecution and the one created above lambda-dynamodb-url-shortener

Create shortCut LAmbda
Create retrieval Lambda
Create API 




TEST EVENT FOR CREATE
{
  "body": "{\"long_url\": \"https://www.loveholidays.com/sem/cheap.html?WT.mc_id=pgo-35492155817-aud-1265061430767:kwd-18055111&ch=gen&gad_source=1&gclid=Cj0KCQjwjLGyBhCYARIsAPqTz19Qm2bhdJpOlqJmlDxoUAcQaio8IxpJyBY3AS90D3wyQcaAW6rbzvoaApKjEALw_wcB\"}"
}

TEST EVENT FOR GET
