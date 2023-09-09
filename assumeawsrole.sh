#!/bin/bash

# Usage: ./assume-administrator-role.sh [optional_profile_name]

# Default role name to assume
role_to_assume="ServiceRole"

# Use the specified AWS CLI profile if provided as an argument
if [ $# -eq 1 ]; then
    profile="$1"
else
    profile="default"  # Use the default profile if no argument provided
fi

# Set the duration (in seconds) for the temporary credentials
duration="${2:-900}"  # Default duration is 15 minutes (900 seconds)

# Set the AWS_DEFAULT_REGION based on the selected profile or the default region
if [ "$profile" == "default" ]; then
    region=$(aws configure get region)
else
    region=$(aws configure get region --profile "$profile")  # Get region from the specified profile
fi

# Assume the role and capture the temporary credentials
credentials=$(aws sts assume-role --role-arn "arn:aws:iam::AWSACCOUNTNUMBER:role/$role_to_assume" \
    --role-session-name "ServiceSession" --profile "$profile" --duration-seconds "$duration")

# Extract the temporary credentials
access_key=$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')
secret_key=$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')
session_token=$(echo "$credentials" | jq -r '.Credentials.SessionToken')

# Set temporary credentials as environment variables
export AWS_ACCESS_KEY_ID="$access_key"
export AWS_SECRET_ACCESS_KEY="$secret_key"
export AWS_SESSION_TOKEN="$session_token"
export AWS_DEFAULT_REGION="$region"
