import json

def lambda_handler(event, context):
    # Print the event data to see what's being passed in
    print("Event: ", json.dumps(event))

    # Extract bucket and object information
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']
        print(f"New object {object_key} was added to bucket {bucket_name}")

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda triggered by S3!')
    }
