terraform {
  cloud {
    organization = "jfarnell-ps-demo"

    workspaces {
      name = "iam-policy-attach"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "policy fto provide ec2 & s3 actions"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Stmt1667269052650",
          "Action" : "ec2:*",
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Sid" : "Stmt1667269065452",
          "Action" : "s3:*",
          "Effect" : "Allow",
          "Resource" : "*"
        }
      ]
  })

}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Sid    = ""
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
    }
  )
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

#VPC & associated resources




#security group
resource "aws_security_group" "agents" {
  name   = "${var.friendly_name_prefix}-tfc-cloud-agents-sg"
  vpc_id = var.vpc_id
  tags   = merge({ "Name" = "${var.friendly_name_prefix}-tfc-cloud-agents-sg" }, var.common_tags)
}

resource "aws_security_group_rule" "egress_https" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow HTTPS traffic egress."

  security_group_id = aws_security_group.agents.id
}

resource "aws_security_group_rule" "egress_http" {
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow HTTP traffic egress."

  security_group_id = aws_security_group.agents.id
}

resource "aws_security_group_rule" "ingress_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow SSH traffic ingress."

  security_group_id = aws_security_group.agents.id
}

#create ec2

resource "aws_instance" "test" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.agents.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  key_name = "key"
  associate_public_ip_address = true

  tags = {
    Name = "Test Name_2"
  }
}

