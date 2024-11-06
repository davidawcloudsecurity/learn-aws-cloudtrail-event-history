#!/bin/bash

# Prompt the user for endpoint name
read -p "Enter the endpoint name: " ENDPOINT_NAME

# Prompt the user for start and end dates
read -p "Enter start date (YYYY-MM-DD): " START_DATE
read -p "Enter end date (YYYY-MM-DD): " END_DATE

# Convert the dates to seconds since 1970-01-01 (epoch time) for comparison
START_TIMESTAMP=$(date -d "$START_DATE" +%s)
END_TIMESTAMP=$(date -d "$END_DATE" +%s)

# Loop through each day from start date to end date
CURRENT_TIMESTAMP=$START_TIMESTAMP
while [ "$CURRENT_TIMESTAMP" -le "$END_TIMESTAMP" ]; do
    # Convert the current timestamp back to date format
    CURRENT_DATE=$(date -d "@$CURRENT_TIMESTAMP" +%Y-%m-%d)

    # Set start-time and end-time for the CloudWatch command
    START_TIME="${CURRENT_DATE}T00:00:00Z"
    END_TIME="${CURRENT_DATE}T23:59:59Z"

    # Execute the CloudWatch get-metric-statistics command for each day
    echo "Fetching metrics for date: $CURRENT_DATE with endpoint: $ENDPOINT_NAME"
    aws cloudwatch get-metric-statistics \
        --namespace AWS/SageMaker \
        --metric-name Invocations \
        --dimensions Name=EndpointName,Value="$ENDPOINT_NAME" \
                     Name=VariantName,Value=AllTraffic \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --period 3600 \
        --statistics Sum

    # Move to the next day (increment by 86400 seconds which is 1 day)
    CURRENT_TIMESTAMP=$((CURRENT_TIMESTAMP + 86400))
done
