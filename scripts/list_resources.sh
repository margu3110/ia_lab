#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

PROFILE="${1:-}"

REGION="${AWS_REGION:-us-east-1}"
PROJECT="ia-lab"
ENVIRONMENT="dev"

# ------------------------------------------------------------
# Argument validation
# ------------------------------------------------------------

if [[ -z "$PROFILE" ]]; then
  echo "Usage: $0 <aws-profile>"
  echo
  echo "Example:"
  echo "  $0 lino"
  echo
  exit 1
fi

# Verify that the AWS profile works
if ! aws sts get-caller-identity \
  --profile "$PROFILE" \
  --region "$REGION" >/dev/null 2>&1; then

  echo "ERROR: Unable to authenticate using AWS profile '$PROFILE'."
  echo
  echo "Available profiles:"
  aws configure list-profiles
  echo

  exit 1
fi

# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

echo
echo "=========================================="
echo " IA Lab - AWS Resources"
echo "=========================================="
echo
echo "Profile:     $PROFILE"
echo "Region:      $REGION"
echo "Project:     $PROJECT"
echo "Environment: $ENVIRONMENT"
echo

# ------------------------------------------------------------
# Account information
# ------------------------------------------------------------

echo "=== AWS Account ==="

aws sts get-caller-identity \
  --profile "$PROFILE" \
  --region "$REGION" \
  --query '[Account,Arn]' \
  --output table

echo

# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------

echo "=== VPC ==="

aws ec2 describe-vpcs \
  --profile "$PROFILE" \
  --region "$REGION" \
  --filters \
    "Name=tag:Project,Values=$PROJECT" \
    "Name=tag:Environment,Values=$ENVIRONMENT" \
  --query 'Vpcs[*].[VpcId,CidrBlock,State,Tags[?Key==`Name`].Value | [0]]' \
  --output table

echo

# ------------------------------------------------------------
# Subnets
# ------------------------------------------------------------

echo "=== Subnets ==="

aws ec2 describe-subnets \
  --profile "$PROFILE" \
  --region "$REGION" \
  --filters \
    "Name=tag:Project,Values=$PROJECT" \
    "Name=tag:Environment,Values=$ENVIRONMENT" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,State,MapPublicIpOnLaunch,Tags[?Key==`Name`].Value | [0]]' \
  --output table

echo

# ------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------

echo "=== Internet Gateways ==="

aws ec2 describe-internet-gateways \
  --profile "$PROFILE" \
  --region "$REGION" \
  --filters \
    "Name=tag:Project,Values=$PROJECT" \
    "Name=tag:Environment,Values=$ENVIRONMENT" \
  --query 'InternetGateways[*].[InternetGatewayId,Attachments[0].State,Tags[?Key==`Name`].Value | [0]]' \
  --output table

echo

# ------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------

echo "=== Route Tables ==="

aws ec2 describe-route-tables \
  --profile "$PROFILE" \
  --region "$REGION" \
  --filters \
    "Name=tag:Project,Values=$PROJECT" \
    "Name=tag:Environment,Values=$ENVIRONMENT" \
  --query 'RouteTables[*].[RouteTableId,VpcId,Tags[?Key==`Name`].Value | [0]]' \
  --output table

echo

# ------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------

echo "=== Security Groups ==="

aws ec2 describe-security-groups \
  --profile "$PROFILE" \
  --region "$REGION" \
  --filters \
    "Name=tag:Project,Values=$PROJECT" \
    "Name=tag:Environment,Values=$ENVIRONMENT" \
  --query 'SecurityGroups[*].[GroupId,GroupName,VpcId,Description]' \
  --output table

echo

# ------------------------------------------------------------
# EC2 Instances
# ------------------------------------------------------------

echo "=== EC2 Instances ==="

aws ec2 describe-instances \
  --profile "$PROFILE" \
  --region "$REGION" \
  --filters \
    "Name=tag:Project,Values=$PROJECT" \
    "Name=tag:Environment,Values=$ENVIRONMENT" \
  --query 'Reservations[].Instances[*].[InstanceId,InstanceType,State.Name,InstanceLifecycle,PrivateIpAddress,PublicIpAddress,Placement.AvailabilityZone,Tags[?Key==`Name`].Value | [0]]' \
  --output table

echo

# ------------------------------------------------------------
# Spot Instance Requests
# ------------------------------------------------------------

echo "=== Spot Instance Requests ==="

aws ec2 describe-spot-instance-requests \
  --profile "$PROFILE" \
  --region "$REGION" \
  --query 'SpotInstanceRequests[*].[SpotInstanceRequestId,State,Status.Code,InstanceId,InstanceType,SpotPrice,CreateTime]' \
  --output table

echo

# ------------------------------------------------------------
# IAM Role
# ------------------------------------------------------------

echo "=== IAM Role ==="

if aws iam get-role \
  --profile "$PROFILE" \
  --role-name "$PROJECT" >/dev/null 2>&1; then

  aws iam get-role \
    --profile "$PROFILE" \
    --role-name "$PROJECT" \
    --query 'Role.[RoleName,Arn,CreateDate]' \
    --output table
else
  echo "IAM role '$PROJECT' not found"
fi

echo

# ------------------------------------------------------------
# IAM Instance Profile
# ------------------------------------------------------------

echo "=== IAM Instance Profile ==="

if aws iam get-instance-profile \
  --profile "$PROFILE" \
  --instance-profile-name "$PROJECT" >/dev/null 2>&1; then

  aws iam get-instance-profile \
    --profile "$PROFILE" \
    --instance-profile-name "$PROJECT" \
    --query 'InstanceProfile.[InstanceProfileName,Arn,CreateDate,Roles[0].RoleName]' \
    --output table
else
  echo "IAM instance profile '$PROJECT' not found"
fi

echo

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

echo "=========================================="
echo " Done"
echo "=========================================="
echo

