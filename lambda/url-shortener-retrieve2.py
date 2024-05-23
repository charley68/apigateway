
import os
import json
import boto3

ddb = boto3.resource('dynamodb', region_name = 'eu-west-2').Table('url-shortener-table2')

def lambda_handler(event, context):
    short_id = event.get('short_id')
    print(f"shortId={short_id}")

    try:
        item = ddb.get_item(Key={'short_id': short_id}) #look up the take the short id value in dynamo
        long_url = item.get('Item').get('long_url') #take the long_url value corresponding to the short id
        print(f"****** LongURL={long_url}")
    except:
        print("Failed to locate short_id")
        return {
            'statusCode': 301,
            'location': 'https://blog.thomasnet.com/hs-fs/hubfs/shutterstock_774749455.jpg?width=1200&name=shutterstock_774749455.jpg'
        }
    
    #return long_url and the redirection http status code 301
    return {
        "statusCode": 301,
        "location": long_url
    }
