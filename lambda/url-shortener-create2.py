import os
import json
import boto3
from string import ascii_letters, digits
from random import choice, randint
from time import strftime, time
from urllib import parse

#app_url = os.getenv('APP_URL') #The app_url will be your domain name, as this will be returned to the client with the short id
string_format = ascii_letters + digits

ddb = boto3.resource('dynamodb', region_name = 'eu-west-2').Table('url-shortener-table2') #Set region and Dynamo DB table

def generate_timestamp():
    response = strftime("%Y-%m-%dT%H:%M:%S")
    return response

def expiry_date():
    response = int(time()) + int(604800) #generate expiration date for the url based on the timestamp
    return response

def check_id(short_id):
    if 'Item' in ddb.get_item(Key={'short_id': short_id}):
        response = generate_id()
    else:
        return short_id

def generate_id():
    short_id = "".join(choice(string_format) for x in range(randint(12, 16))) #generate unique value for the short url
    print(short_id)
    response = check_id(short_id)
    return response

def lambda_handler(event, context):
    analytics = {}
    print(event)
    short_id = generate_id()
    long_url = json.loads(event.get('body')).get('long_url')
    print(f"SHORTID={short_id}")
    print(f"LONG URL={long_url}")
    timestamp = generate_timestamp()
    ttl_value = expiry_date()

   # analytics['user_agent'] = event.get('headers').get('User-Agent')
   # analytics['source_ip'] = event.get('headers').get('X-Forwarded-For')
    #analytics['xray_trace_id'] = event.get('headers').get('X-Amzn-Trace-Id')

    #if len(parse.urlsplit(long_url).query) > 0:
     #   url_params = dict(parse.parse_qsl(parse.urlsplit(long_url).query))
      #  for k in url_params:
       #     analytics[k] = url_params[k]

    #put value in dynamodb table
    response = ddb.put_item(
        Item={
            'short_id': short_id,
            'long_url': long_url
        }
    )

    try:
        fullURL = 'https://' + event['headers']['Host'] + '/' + event['requestContext']['stage'] + event['path']
    except:
        fullURL = f"..../{short_id}"
        
    print(f"fullURL={fullURL}")


    body_new = '{"short_id":"' +fullURL+'","long_url":"'+long_url+'"}'
    return {"statusCode": 200,"body": body_new} #return the body with long and short url