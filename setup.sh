#!/bin/bash

# Cleanup any existing files
rm -rf manifest.json
rm -rf infra/terraform.tfstate*
rm -rf infra/tf.plan

# Check for required variables
echo "Checking for required environment variables..."
[ -z "${AWS_ACCESS_KEY}" ] && { echo "AWS_ACCESS_KEY must be set!" >&2; exit 1; }
[ -z "${AWS_SECRET_KEY}" ] && { echo "AWS_SECRET_KEY must be set!" >&2; exit 1; }

# Check for existence of dependencies
echo "Checking for required dependencies..."
command -v terraform > /dev/null 2>&1 || { echo "Terraform must be installed on this system! (Try running 'brew install terraform')" >&2; exit 1; }
command -v packer > /dev/null 2>&1 || { echo "Packer must be installed on this system! (Try running 'brew install packer')" >&2; exit 1; }
command -v jq > /dev/null 2>&1 || { echo "jq must be installed on this system! (Try running 'brew install jq')" >&2; exit 1; }

# Validate the packer configuration
echo "Validating packer manifest..."
packer validate packer.json

# Build the AWS AMI
# This outputs a manifest.json file to retrieve the AMI ID
echo "Building ami..."
packer build -var "aws_access_key=$AWS_ACCESS_KEY" -var "aws_secret_key=$AWS_SECRET_KEY" packer.json

AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ":" -f2)
echo "AMI ID set to $AMI_ID"

# Create the Terraform plan
# This outputs a tf.plan file to be used by Terraform
echo "Creating Terraform plan..."
cd infra
terraform init
terraform plan -var 'aws_region=us-east-1' -var "aws_access_key=$AWS_ACCESS_KEY" -var "aws_secret_key=$AWS_SECRET_KEY" -var "ami=$AMI_ID" -out tf.plan

# Run Terraform to build all the things!
echo "Creating AWS infrastructure..."
terraform apply "tf.plan"

echo "Deployment complete!"
