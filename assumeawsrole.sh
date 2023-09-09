#!/bin/bash

# Usage: ./assumeawsrole.sh --account <AWS_account_number> [--profile <AWS_profile>] [--duration <duration_in_seconds>] [--role <AWS_role>]

# Initialize variables with default values
profile="default"
duration="900"  # Default duration is 15 minutes (900 seconds)
role_to_assume="AdministratorRole" # Default role name to assume

# Function to display usage information
display_usage() {
    echo "Usage: $0 --account <AWS_account_number> [--profile <AWS_profile>] [--duration <duration_in_seconds>] [--role <AWS_role>] [--help]"
    echo ""
    echo "Options:"
    echo "  --account     AWS account number (required)"
    echo "  --profile     AWS profile name (optional, default: 'default')"
    echo "  --duration    Duration in seconds for temporary credentials (optional, default: 900)"
    echo "  --role        The AWS role to assume for session (optional, default: AdministratorRole)"
    echo "  --help        Display this usage information"
    echo ""
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --account)
            account="$2"
            shift 2
            ;;
        --profile)
            profile="$2"
            shift 2
            ;;
        --duration)
            duration="$2"
            shift 2
            ;;
        --role)
            duration="$2"
            shift 2
            ;;
        --help)
            display_usage
            return
            ;;
        *)
            echo "Invalid argument: $1"
            shift 1  # Shift by 1 to consume the invalid argument and continue            
            ;;
    esac
done

# Check if the required account parameter is provided
if [ -z "$account" ]; then
    echo "Error: AWS Account Number parameter (account) is required."
    echo ""
    display_usage
    return
fi

# Set the AWS_DEFAULT_REGION based on the selected profile or the default region
if [ "$profile" == "default" ]; then
    region=$(aws configure get region)
else
    region=$(aws configure get region --profile "$profile")  # Get region from the specified profile
fi

# Assume the role and capture the temporary credentials
credentials=$(aws sts assume-role --role-arn "arn:aws:iam::$account:role/$role_to_assume" \
    --role-session-name "AssumeSession" --profile "$profile" --duration-seconds "$duration")

# Extract the temporary credentials
access_key=$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')
secret_key=$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')
session_token=$(echo "$credentials" | jq -r '.Credentials.SessionToken')

# Set temporary credentials as environment variables
export AWS_ACCESS_KEY_ID="$access_key"
export AWS_SECRET_ACCESS_KEY="$secret_key"
export AWS_SESSION_TOKEN="$session_token"
export AWS_DEFAULT_REGION="$region"
