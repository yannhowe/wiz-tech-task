terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
  default_tags {
    tags = {
      name    = "mongodb-server"
      project = "wiz-tech-task"
      owner   = "kyh"
    }
  }
}

#provider "kubernetes" {
#  host                   = aws_eks_cluster.wiz-tech-task-eks-cluster.endpoint
#  cluster_ca_certificate = base64decode(aws_eks_cluster.wiz-tech-task-eks-cluster.certificate_authority.0.data)
#  exec {
#    api_version = "client.authentication.k8s.io/v1beta1"
#    command     = "aws"
#    args = [
#      "eks",
#      "get-token",
#      "--cluster-name",
#      "wiz-tech-task-eks-cluster"
#    ]
#  }
#}

provider "kubectl" {
  host                   = aws_eks_cluster.wiz-tech-task-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.wiz-tech-task-eks-cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.wiz-tech-task-eks-cluster.name
    ]
  }
  load_config_file = false
}

#provider "kubectl" {
#  host                   = "https://216521BE75B3073598CA8A90EE42D018.gr7.ap-southeast-1.eks.amazonaws.com"
#  cluster_ca_certificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EVXhNVEF6TXpZME1Wb1hEVE16TURVd09EQXpNelkwTVZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTHl3CkhtUEJkTFFaaW5QTDVmOU11aEpmcFRJaUxseVY3WUJWQk5LYjU0ZmxmRi9kamdxUXZKOS9QRGxGMlN6SjFwM0oKTDVYZ0hSUDRjMkEzVEMrTmZ3U0xlWnMwVVJtclZJUEFXYWpvZi9IcFJEZDBzOXR1ZGN2STVvVVMzNkt1ZDVXYwpyWnNUdUwrSXpGcVR3MWRmcCtvTE5sZFVOL2wycG8rZmpVeGRaYWhmdHlMN1J0R1psQzdBTW9pWkZubGJNZm52Cks2UytNVnRWNkZncXZDOVFYVVlqTmxzVEtZUHNYVW05d3BUOEZSODFsR1R6emllaE5xT21yOC9odklhLy9DYzYKZHp2MXlJWjAzeFJnWHdZeUd5cHBEeEl5ZUdvYnNpbHA5QXVuZC95ZlBCQVE4UXJuWWNOUjBCc05tMlNLOGJTZQpXSDBzeGZLakM0bURraGVHRkJVQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZBbXZoQk9KZkdmUWQ1aFg3TDhPbE1CWDhBY0NNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRTRxLzZGdXllbmVIbkRzUTF6ZApxVkY5NTZNK2Q1bjRjTExDSnRzZTNlMVk1ZWhMZEtNcW5hUnZZRTg3UFpvbjlBUTFVaHZnc0gyUERueVYwR29uCmJlRHFqQ1YvaXlyckk2T3NPYk5nRW1JT2MyRk9nOCtHUDBweVR3TllEUzBudUdRK0QzZ2NVT0VGcHExNlVhQ2EKdmk0aHNDelZSOE0xLzRrekFIcWo3Z0tubFlXMzlqVlQxNFNyM1RNL29yaVhoMDVsdzlPdmxyNHRGKytOc2xDbApzaEtBNGxqU2h2QkFLckRhNlVxM0lTczkzejUyMEN4VUVBblJUcmMvaERTRnMwSlRyUThxMVZ0b2hBY1NUM2w0CmxSQjBaVmFEOVFtbmVCOTdRMTUwOVZCcjNEVXBjNzB2d1M2T2U2NnVKUXZ2K2tTdzJiRC9OenhxK0doWDVoQTMKdmtFPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
#  token                  = "k8s-aws-v1.aHR0cHM6Ly9zdHMuYXAtc291dGhlYXN0LTEuYW1hem9uYXdzLmNvbS8_QWN0aW9uPUdldENhbGxlcklkZW50aXR5JlZlcnNpb249MjAxMS0wNi0xNSZYLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFUM0RYTktJRU9MNzVZR1A1JTJGMjAyMzA1MTElMkZhcC1zb3V0aGVhc3QtMSUyRnN0cyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjMwNTExVDA2MzEyMVomWC1BbXotRXhwaXJlcz02MCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QlM0J4LWs4cy1hd3MtaWQmWC1BbXotU2lnbmF0dXJlPTcyZThiMzQwMDJkZTcyNDFmZTYwZWMzYTJkNTNlMzE3MWUwZTI1MWVkN2JmYjc5OTQ5M2M3OGU0Mjk0MjYwYjA"
#  load_config_file       = false
#}