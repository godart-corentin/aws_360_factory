#!/usr/bin/env bash

######################################################################
# Get the AMI_ID
######################################################################

echo "Getting AMI Id..."

AMI_NAME="ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"

AMI_ID=$(aws ec2 describe-images \
                --output text \
                --filters "Name=name,Values=${AMI_NAME}"  \
                --query "(reverse(sort_by(Images, &CreationDate)) | [0]).ImageId")

echo "Got AMI Id: ${AMI_ID}"

######################################################################
# Get the VPC Id
######################################################################

echo "Getting VPC Id..."

VPC_ID=$(aws ec2 describe-vpcs \
              --output text \
              --query "Vpcs[?IsDefault] | [0].VpcId")

echo "Got VPC Id: ${VPC_ID}"


######################################################################
# Get the Subnet Id within the VPC
######################################################################

echo "Getting Subnet Id..."

SUBNET_ID=$(aws ec2 describe-subnets \
                  --output text \
                  --query "Subnets[?VpcId == '${VPC_ID}' && AvailabilityZone == 'us-east-1b'] | [0].SubnetId")

echo "Got Subnet Id: ${SUBNET_ID}"


######################################################################
# Get the Security groups Id
######################################################################

echo "Getting Security Group Id..."

SG="ops"

SG_ID=$(aws ec2 describe-security-groups \
                  --output text \
                  --query "SecurityGroups[?VpcId == '${VPC_ID}' && GroupName == '${SG}'] | [0].GroupId")

echo "Got Security Group Id: ${SG_ID}"

######################################################################
### Provision EC2 Server
######################################################################

echo "Provisioning EC2 instance..."

INSTANCE_COUNT=1
INSTANCE_TYPE='t2.micro'

PROVISION=$(aws ec2 run-instances \
                  --image-id "${AMI_ID}" \
                  --count "${INSTANCE_COUNT}" \
                  --instance-type "${INSTANCE_TYPE}" \
                  --security-group-ids "${SG_ID}" \
                  --subnet-id "${SUBNET_ID}")

echo "Ec2 Instance ready, here are the details:"
echo ${PROVISION}