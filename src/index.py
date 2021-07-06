redir_map = {
# TF template for %{ for src, dest in domain_mapping }
    '${src}': '${dest}',
# TF template endfor %{ endfor }
}

def handler(event, lambda_context):
    request_domain = event['requestContext']['domainName'] # test.example.com
    request_path = event['requestContext']['path'] # /

    print(f'Request: {request_domain}{request_path}')

    if request_domain not in redir_map:
        return {
            "statusCode": 500,
            "body": f'"Could not find {request_domain} in redir_map!"'
        }

    location = redir_map[request_domain] + request_path

    print(f'Redirecting to {location}')

    return {
        "statusCode": '${redirect_code}',
        "headers": {
            "Location": location,
        },
        "body": f'"Redirecting to {location}"'
    }
