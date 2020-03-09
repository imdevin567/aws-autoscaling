# AWS Autoscaling Automation

This project contains three parts:

1. A Python/Flask application with a single endpoint to generate load
2. A Packer manifest to build a custom AMI containing the app above
3. Terraform scripts to build the AWS infrastructure

## Dependencies

- Terraform (https://www.terraform.io)
- Packer (https://packer.io)
- jq (https://stedolan.github.io/jq/)

## Get Started

1. Set required environment variables `AWS_ACCESS_KEY` and `AWS_SECRET_KEY`
2. Run `setup.sh`

When completed, you can test autoscaling by hitting the endpoint continuously:

```bash
$  watch -n 5 curl 'http://YOUR_ELB_ADDRESS/killme'
```

Due to the grace period after creation, it is recommended to wait at least 5 min prior to autoscaling.

You can also change the CPU usage and length of time by using the query parameters `usage` and `time`, respectively. i.e.

```bash
$  curl 'http://YOUR_ELB_ADDRESS/killme?usage=0.99&time=20'
```

## Get Un-Started

To remove all AWS resources created by this project, destroy via Terraform:

```bash
$  cd infra
$  terraform destroy -auto-approve
```
