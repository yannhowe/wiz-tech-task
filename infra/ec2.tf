data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220401"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "wiz-technical-task-mongodb-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.kyh-mba-pubkey.id
  iam_instance_profile        = aws_iam_instance_profile.wiz-tech-task-ec2-instance-profile.name
  associate_public_ip_address = true
  #user_data                   = file("${path.module}/mongodb_install.sh")
  subnet_id              = aws_subnet.wiz-tech-task-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_from_vpc.id, aws_security_group.allow_mongo_from_vpc.id, aws_security_group.allow_icmp_from_everywhere.id]
  tags = {
    Name = "wiz-technical-task-mongodb-server"
  }
  depends_on = [
    aws_iam_instance_profile.wiz-tech-task-ec2-instance-profile
  ]
  user_data = <<EOF
#!/bin/bash
sudo apt-get install gnupg
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
--dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
# Install 6.0.0 - https://www.mongodb.com/docs/manual/release-notes/6.0/#6.0.0---jul-19--2022
sudo apt-get install -y unzip tree mongodb-org=6.0.0 mongodb-org-database=6.0.0 mongodb-org-server=6.0.0 mongodb-org-mongos=6.0.0 mongodb-org-tools=6.0.0
ps --no-headers -o comm 1
sudo systemctl daemon-reload
sudo systemctl status mongod
sudo systemctl enable mongod
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
tee /etc/mongod.conf << END
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
net:
  port: 27017
  bindIp: 0.0.0.0
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
END
sudo systemctl start mongod
EOF
}

resource "aws_instance" "wiz-technical-task-bastion-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.kyh-mba-pubkey.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.wiz-tech-task-ec2-instance-profile.name
  #user_data                   = file("${path.module}/mongodb_install_dbtools.sh")
  subnet_id              = aws_subnet.wiz-tech-task-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_from_everywhere.id, aws_security_group.allow_icmp_from_everywhere.id]
  tags = {
    Name = "wiz-technical-task-bastion-server"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt-get install gnupg
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
--dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
# Install 6.0.0 - https://www.mongodb.com/docs/manual/release-notes/6.0/#6.0.0---jul-19--2022
sudo apt-get install -y unzip tree mongodb-org-tools=6.0.0
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
tee -a /home/ubuntu/mongodb_backup.sh << END
#!/bin/bash
mkdir -p /home/ubuntu/mongodb_backups
mongodump -h ${aws_instance.wiz-technical-task-mongodb-server.private_ip}:27017 -o /home/ubuntu/mongodb_backups
/usr/local/bin/aws s3 sync /home/ubuntu/mongodb_backups/ s3://${aws_s3_bucket.wiz-tech-task-mongodb-bucket.id}
END
EOF
}

resource "aws_key_pair" "kyh-mba-pubkey" {
  key_name   = "kyh-mba-pubkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfwBC/YFf+V5kHJW+oxBacoaezWeXOLuJa18ulhJkozbPkfdmW/tjRBuMsrDtmk5PyGfGmDczhflX2isNRX+afdLcUCvFDC4WdwvcvJZn6N/pi97PFVUroqQ2we9ZYq4kzxLJfYZJHxe8oA4fDCEkNsyMOub4nK+TQoiV9C6QTqOo6OLK/qZjS2zMAF1KhU6yHvtT23NBlrcRBt7S9pJkdZVPSb8oTiz3v5XDcN2eakD8MuW1mcGY+DZReUCFLRH088kfJbzOAT5EJIQh/bXvqAJnjF9ecL/CMxR69OG5bTkztAsPye9aWdkg69m1TB4tXK39miGs/PG8p+oiwSSJLqgiLQtluFPqiefUbwakSY9seDhE8qX5MmE9NkgRIOMmZxTox1+Y1ko6cp9R9zVboW4xuZ8W8iYkPBKWoAwlXV19jfZu5T/NWXcX3BGUEK3M459mrQkQxlrPywzFcsTVcNrFlFhx0LuqOT8B1Kg1RtJDdCDY3ohoq1L0nuOR8KOc= yannhowe@Yanns-MacBook-Air.local"
}


data "aws_iam_policy_document" "wiz-tech-task-ec2-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "wiz-tech-task-ec2-s3-bucket-write-policy" {
  name = "wiz-tech-task-ec2-s3-bucket-write-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.wiz-tech-task-mongodb-bucket.id}/*",
        ]
      },
            {
        Effect = "Allow",
        Action = [
          "ec2:*"
        ],
        Resource = [
          "*",
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "wiz-tech-task-ec2-instance-profile" {
  name = "wiz-tech-task-ec2-instance-profile"
  role = aws_iam_role.wiz-tech-task-ec2-full-access-role.name
}

resource "aws_iam_role" "wiz-tech-task-ec2-full-access-role" {
  name                = "wiz-tech-task-ec2-full-access-role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.wiz-tech-task-ec2-assume-role.json
  managed_policy_arns = [aws_iam_policy.wiz-tech-task-ec2-s3-bucket-write-policy.arn]
}


output "ssh-bastion-host" {
  value = "ssh -A ubuntu@${aws_instance.wiz-technical-task-bastion-server.public_ip}"
}

output "ssh-mongo-host" {
  value = "ssh ubuntu@${aws_instance.wiz-technical-task-mongodb-server.private_ip}"
}
