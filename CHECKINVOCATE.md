### Check date for endpoint
Raw
```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteEndpoint | jq -r '.Events[]'
```
Specific variable
```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateEndpoint | \
jq -r '.Events[0].CloudTrailEvent | fromjson | .userIdentity.sessionContext.attributes.creationDate'
```
Organized table
```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateEndpoint | \
jq -r '.Events[] | [
    (.CloudTrailEvent | fromjson | .userIdentity.sessionContext.sessionIssuer.userName),
    (.CloudTrailEvent | fromjson | .userIdentity.sessionContext.attributes.creationDate),
    (.CloudTrailEvent | fromjson | .sourceIPAddress),
    (.CloudTrailEvent | fromjson | .requestParameters.endpointName),
    (.CloudTrailEvent | fromjson | .requestParameters.endpointConfigName)
] | @tsv' | column -t -s $'\t' -N "Username,CreationDate,SourceIPAddress,EndpointName,EndpointConfig"
```
Specific name
```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteEndpoint | jq -r '.Events[] | [
    (.CloudTrailEvent | fromjson | .userIdentity.sessionContext.sessionIssuer.userName),
    (.CloudTrailEvent | fromjson | .userIdentity.sessionContext.attributes.creationDate),
    (.CloudTrailEvent | fromjson | .sourceIPAddress),
    (.CloudTrailEvent | fromjson | .requestParameters.endpointName),
    (.CloudTrailEvent | fromjson | .requestParameters.endpointConfigName)
] | @tsv' | column -t -s $'\t' -N "Username,CreationDate,SourceIPAddress,EndpointName,EndpointConfig" | grep -E 'jumpstart-dft-llama-3-1-405b-instruct-fp8-10($|\s)'
```
### Check metric for invocation aws cli
period 60 = 1 min
```bash
aws cloudwatch get-metric-statistics   --namespace AWS/SageMaker   --metric-name Invocations   --dimensions Name=EndpointName,Value=tinyllama-1-1b-intermediate-step-1431k--24-10-28-08-41-51-456 Name=VariantName,Value=AllTraffic Name=EndpointConfigName,Value=tinyllama-1-1b-intermediate-step-1431k--24-10-28-08-41-51-456   --start-time 2024-10-22T00:00:00Z   --end-time 2024-10-23T00:00:00Z   --period 60   --statistics Sum
```
### Match exact words
```bash
cat file | grep -E '(^|\s)tinyllama-1-1b-intermediate-step-1431k--24-10-28-08-41-51-456($|\s)'
cat file | grep -E 'tinyllama-1-1b-intermediate-step-1431k--24-10-28-08-41-51-456($|\s)'
```
### How to trace endpoint via cloudtrail
Raw data
```bash
aws cloudtrail lookup-events   --lookup-attributes AttributeKey=EventName,AttributeValue=DescribeEndpoint   --start-time 2024-10-11T17:03:10+05:30   --end-time 2024-10-18T17:03:10+05:30   | jq '.Events[] | select(.CloudTrailEvent | contains("tinyllama-1-1b-intermediate-step-1431k--24-10-28-08-41-51-456"))'
```

Organize table
```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteEndpoint | jq -r '.Events[] | [
    (.CloudTrailEvent | fromjson | .userIdentity.sessionContext.sessionIssuer.userName),
    (.CloudTrailEvent | fromjson | .userIdentity.sessionContext.attributes.creationDate),
    (.CloudTrailEvent | fromjson | .sourceIPAddress),
    (.CloudTrailEvent | fromjson | .requestParameters.endpointName),
    (.CloudTrailEvent | fromjson | .requestParameters.endpointConfigName)
] | @tsv' | column -t -s $'\t' -N "Username,CreationDate,SourceIPAddress,EndpointName,EndpointConfig" | grep -E 'tinyllama-1-1b-intermediate-step-1431k--24-10-28-08-41-51-456($|\s)'
```
### How to invoke endpoint via sdk
```bash
import boto3
import json

# Initialize the SageMaker runtime client
sagemaker_runtime = boto3.client("sagemaker-runtime", region_name="ap-southeast-1")

# Define the endpoint name and payload with an 'inputs' field
endpoint_name = "tinyllama-1-1b-intermediate-step-1431k--24-10-28-08-41-51-456"
payload = {
    "inputs": "Hello"  # Replace with your actual input
}

# Invoke the endpoint
response = sagemaker_runtime.invoke_endpoint(
    EndpointName=endpoint_name,
    ContentType="application/json",
    Body=json.dumps(payload)
)

# Parse and print the response
result = json.loads(response['Body'].read().decode())
print(result)
```
