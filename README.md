# Wiz Technical Task
An API that tracks tasks. Deployed using Terraform on AWS.

# Technology & Tooling
- Flask/Python on Kubernetes (EKS)
- MongoDB on EC2
- MongoDB Backups on S3
- Terraform
- AWS

# Quick Start
Prepare your environment
```
# For Mac
brew install terraform, awscli
git clone git@github.com:yannhowe/wiz-tech-task.git
```

Build and push images to ECR
```
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/v4o5r6v9
# rancher desktop
docker build -t public.ecr.aws/v4o5r6v9/tasksapp-python:latest .
docker push public.ecr.aws/v4o5r6v9/tasksapp-python:latest
```

Stand up all infra
```
terraform init
terraform apply
```

Check endpoints and values to use from terraform output
```
TASK_ENDPOINT=SOMETHINGSOMETHING
MONGOEXPRESS_ENDPOINT=SOMETHINGSOMETHING
BASTION_HOST=SOMETHINGSOMETHING
MONGO_HOST=SOMETHINGSOMETHING
```

Add a task using curl
```
for i in {1..3}; do \
    curl -d '{"task": "This is task '$i'"}' -H 'Content-Type: application/json' -X POST http://$TASK_ENDPOINT/task; \
done

curl http://$TASK_ENDPOINT/tasks
```

Check outcome on mongoexpress and API endpoint
```

```

Backup MongoDB
```
# SSH to bastion
ssh -A $BASTION_HOST
# Run backup script 1) Backup 2) Upload to S3
bash -x mongodb_backup.sh
# Check S3 for files
aws s3 ls wiz-tech-task-mongodb-bucket
# Delete everything
aws s3 rb --force s3://wiz-tech-task-mongodb-bucket
```

Minimal Terraform IAM

Sample
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AllocateAddress",
                "ec2:AssociateRouteTable",
                "ec2:AttachInternetGateway",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateInternetGateway",
                "ec2:CreateNatGateway",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateTags",
                "ec2:CreateVpc",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteKeyPair",
                "ec2:DeleteNatGateway",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteVpc",
                "ec2:DescribeAddresses",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNatGateways",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcClassicLink",
                "ec2:DescribeVpcClassicLinkDnsSupport",
                "ec2:DescribeVpcs",
                "ec2:DetachInternetGateway",
                "ec2:DisassociateAddress",
                "ec2:DisassociateRouteTable",
                "ec2:ImportKeyPair",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifySubnetAttribute",
                "ec2:ReleaseAddress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "eks:CreateCluster",
                "eks:CreateNodegroup",
                "eks:DeleteCluster",
                "eks:DeleteNodegroup",
                "eks:DescribeCluster",
                "eks:DescribeNodegroup",
                "eks:TagResource",
                "iam:AddRoleToInstanceProfile",
                "iam:AttachRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:CreatePolicy",
                "iam:CreateRole",
                "iam:DeleteInstanceProfile",
                "iam:DeletePolicy",
                "iam:DeleteRole",
                "iam:DetachRolePolicy",
                "iam:GetInstanceProfile",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:ListPolicyVersions",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:TagInstanceProfile",
                "iam:TagPolicy",
                "iam:TagRole",
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:DeleteBucketPolicy",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketAcl",
                "s3:GetBucketCORS",
                "s3:GetBucketLogging",
                "s3:GetBucketObjectLockConfiguration",
                "s3:GetBucketPolicy",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetBucketRequestPayment",
                "s3:GetBucketTagging",
                "s3:GetBucketVersioning",
                "s3:GetBucketWebsite",
                "s3:GetEncryptionConfiguration",
                "s3:GetLifecycleConfiguration",
                "s3:GetObjectTagging",
                "s3:GetReplicationConfiguration",
                "s3:ListBucket",
                "s3:PutBucketPolicy",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutBucketTagging",
                "sts:DecodeAuthorizationMessage",
                "sts:GetCallerIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```

Finding minimal IAM using iamlive proxy
```
# Run proxy container locally
docker run \
  -p 80:10080 \
  -p 443:10080 \
  --name iamlive-test \
  -it unfor19/iamlive-docker \
  --mode proxy \
  --bind-addr 0.0.0.0:10080 \
  --force-wildcard-resource \
  --output-file "/app/iamlive.log"

# Configure proxy and AWS CLI
export AWS_ACCESS_KEY_ID="SOMETHINGSOMETHING"
export AWS_SECRET_ACCESS_KEY="SOMETHINGSOMETHINGSOMETHINGSOMETHING"
export HTTP_PROXY=http://127.0.0.1:80
export HTTPS_PROXY=http://127.0.0.1:443
export AWS_CA_BUNDLE="${HOME}/.iamlive/ca.pem"

# Get certs from proxy
docker cp iamlive-test:/home/appuser/.iamlive/ ~/

###
# Run your terraform/AWS cli commands
###

# Clean up after
unset HTTP_PROXY=http://127.0.0.1:80
unset HTTPS_PROXY=http://127.0.0.1:443
unset AWS_CA_BUNDLE="${HOME}/.iamlive/ca.pem"
```


Resources
- [aws](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [kubectl_manifest](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/kubectl_manifest)
- https://levelup.gitconnected.com/deploy-your-first-flask-mongodb-app-on-kubernetes-8f5a33fa43b4
- https://github.com/mongo-express/mongo-express
- https://github.com/iann0036/iamlive