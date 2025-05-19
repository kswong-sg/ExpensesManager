import os
import json
import boto3
from decimal import Decimal

s3 = boto3.client('s3')
textract = boto3.client('textract')
ddb = boto3.resource('dynamodb').Table(os.environ['TABLE'])

def process(event, context):
    # Expecting API Gateway proxy integration
    body = json.loads(event.get('body', '{}'))
    key = body.get('s3Key')
    bucket = os.environ['BUCKET']

    # Download the file from S3
    obj = s3.get_object(Bucket=bucket, Key=key)
    content = obj['Body'].read()

    # Determine file type
    if key.lower().endswith('.csv'):
        text = content.decode('utf-8')
        transactions = parse_csv(text)
    else:
        resp = textract.analyzeExpense(Document={'S3Object': {'Bucket': bucket, 'Name': key}})
        transactions = extract_transactions_from_textract(resp)

    # Stitch multi-page transactions
    stitched = stitch_pages(transactions)

    # Classify and store each transaction
    for tx in stitched:
        category = classify(tx)
        tx['category'] = category
        ddb.put_item(Item=to_ddb_item(tx))

    return {
        'statusCode': 200,
        'body': json.dumps({'processed': len(stitched)})
    }

def parse_csv(text):
    # Basic CSV parser: override for different formats
    lines = text.splitlines()
    header = lines[0].split(',')
    transactions = []
    for row in lines[1:]:
        vals = row.split(',')
        tx = dict(zip(header, vals))
        transactions.append(tx)
    return transactions

def extract_transactions_from_textract(resp):
    # Simplest textract expense extraction
    transactions = []
    for exp in resp.get('ExpenseDocuments', []):
        for line in exp.get('LineItemGroups', []):
            for item in line.get('LineItems', []):
                tx = {
                    'Description': get_textract_value(item, 'ITEM'),
                    'Amount': float(get_textract_value(item, 'PRICE', default=0)),
                    'Date': get_textract_value(item, 'DATE', default=None)
                }
                transactions.append(tx)
    return transactions

def get_textract_value(item, key, default=''):
    for field in item.get('LineItemExpenseFields', []):
        if field.get('Type', {}).get('Text') == key:
            return field.get('ValueDetection', {}).get('DetectedText', default)
    return default

def stitch_pages(transactions):
    # Example: carry forward last date if missing
    last_date = None
    stitched = []
    for tx in transactions:
        if tx.get('Date'):
            last_date = tx['Date']
        else:
            tx['Date'] = last_date
        stitched.append(tx)
    return stitched

def classify(tx):
    # Placeholder: replace with real model inference
    text = tx.get('Description', '').lower()
    if 'uber' in text or 'taxi' in text:
        return 'Transport'
    if 'shell' in text or 'petrol' in text:
        return 'Automobile'
    if 'amazon' in text or 'store' in text:
        return 'Shopping'
    return 'Uncategorized'

def to_ddb_item(tx):
    # Convert to DynamoDB-friendly types
    item = {
        'txId': tx.get('Date','') + '|' + str(tx.get('Amount','')),
        'date': tx.get('Date', ''),
        'amount': Decimal(str(tx.get('Amount', 0))),
        'description': tx.get('Description', ''),
        'category': tx.get('category', '')
    }
    return item
