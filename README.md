Terraform CF Example
------

This project provides an example terraform setup that deploys, but fails to execute
a graphql query.

## Getting Setup

1. Deploy: `terraform apply`
2. Setup DB: `./setup_db.sh`

## Testing

Running the following query

```graphql
query {
  accounts {
    id
    name
  }
}
```

returns with

```json
{
  "errors": [
    "An error occurred (500) when calling the ExecuteStatement operation (reached max retries: 4): \n\nGraphQL request:2:3\n1 | query {\n2 |   accounts {\n  |   ^\n3 |     id"
  ]
}
```

and in the localstack logs:

```
2021-01-05T21:38:40:INFO:localstack_ext.services.appsync.graphql_executor: Extracting data from data source "rds", type RELATIONAL_DATABASE

2021-01-05T21:38:40:DEBUG:localstack_ext.services.appsync.graphql_executor: Sending request to data source "rds":

{

"version": "2018-05-29",

"sta

tements": ["\nSELECT\n account_id as id,\n account_name as name\nFROM account"],

"variableMap": {}

}


2021-01-05T21:38:40:WARNING:bootstrap.py: Thread run method <function AdaptiveThreadPool.submit.<locals>._run at 0x7fe4f77f01f0>(None) failed: Unable to find RDS instance "new_test" in cluster "arn:aws:rds:us-east-1:000000000000:cluster:test-cluster" Traceback (most recent call last):

File "/opt/code/localstack/localstack/utils/bootstrap.py", line 581, in run

result = self.func(self.params)

File "/opt/code/localstack/localstack/utils/async_utils.py", line 28, in _run

return fn(*args, **kwargs)

File "/opt/code/localstack/localstack/services/generic_proxy.py", line 597, in handler

response = modify_and_forward(method=method, path=path_with_params, data_bytes=data, headers=headers,

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/utils/aws/aws_utils.py", line 23, in modify_and_forward

File "/opt/code/localstack/localstack/services/generic_proxy.py", line 365, in modify_and_forward

listener_result = listener.forward_request(method=method,

File "/opt/code/localstack/localstack/services/edge.py", line 104, in forward_request

return do_forward_request(api, method, path, data, headers, port=port)

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/services/edge.py", line 155, in do_forward_request

return do_forward_request_orig(api,method,path,data,headers,*args,**kwargs)

File "/opt/code/localstack/localstack/services/edge.py", line 115, in do_forward_request

result = do_forward_request_inmem(api, method, path, data, headers, port=port)

File "/opt/code/localstack/localstack/services/edge.py", line 135, in do_forward_request_inmem

response = modify_and_forward(method=method, path=path, data_bytes=data, headers=headers,

File "/opt/code/localstack/localstack/services/generic_proxy.py", line 365, in modify_and_forward

listener_result = listener.forward_request(method=method,

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/services/rds/rds_listener.py", line 56, in forward_request

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/services/rds/rds_listener.py", line 383, in execute_data_api_request

Exception: Unable to find RDS instance "new_test" in cluster "arn:aws:rds:us-east-1:000000000000:cluster:test-cluster"


2021-01-05T21:38:40:WARNING:localstack.utils.server.http2_server: Error in proxy handler for request POST https://localhost:4566/Execute: Unable to find RDS instance "new_test" in cluster "arn:aws:rds:us-east-1:000000000000:cluster:test-cluster" Traceback (most recent call last):

File "/opt/code/localstack/localstack/utils/server/http2_server.py", line 107, in index

raise result

File "/opt/code/localstack/localstack/utils/bootstrap.py", line 581, in run

result = self.func(self.params)

File "/opt/code/localstack/localstack/utils/async_utils.py", line 28, in _run

return fn(*args, **kwargs)

File "/opt/code/localstack/localstack/services/generic_proxy.py", line 597, in handler

response = modify_and_forward(method=method, path=path_with_params, data_bytes=data, headers=headers,

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/utils/aws/aws_utils.py", line 23, in modify_and_forward

File "/opt/code/localstack/localstack/services/generic_proxy.py", line 365, in modify_and_forward

listener_result = listener.forward_request(method=method,

File "/opt/code/localstack/localstack/services/edge.py", line 104, in forward_request

return do_forward_request(api, method, path, data, headers, port=port)

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/services/edge.py", line 155, in do_forward_request

return do_forward_request_orig(api,method,path,data,headers,*args,**kwargs)

File "/opt/code/localstack/localstack/services/edge.py", line 115, in do_forward_request

result = do_forward_request_inmem(api, method, path, data, headers, port=port)

File "/opt/code/localstack/localstack/services/edge.py", line 135, in do_forward_request_inmem

response = modify_and_forward(method=method, path=path, data_bytes=data, headers=headers,

File "/opt/code/localstack/localstack/services/generic_proxy.py", line 365, in modify_and_forward

listener_result = listener.forward_request(method=method,

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/services/rds/rds_listener.py", line 56, in forward_request

File "/opt/code/localstack/.venv/lib/python3.8/site-packages/localstack_ext/services/rds/rds_listener.py", line 383, in execute_data_api_request
```