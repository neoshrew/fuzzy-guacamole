resource aws_instance this {
  ami                  = data.aws_ami.worker.id
  instance_type        = var.worker_instance_type
  key_name             = aws_key_pair.worker_access.key_name
  iam_instance_profile = aws_iam_instance_profile.worker.id

  tags = {
    Name = "${local.project_prefix}-instance"
  }
}

data aws_ami worker {
  most_recent = true

  filter {
    name   = "name"
    values = [var.worker_ami_name]
  }

  owners = ["amazon"] # Canonical
}

resource aws_key_pair worker_access {
  key_name   = "${local.project_prefix}-worker"
  public_key = var.worker_access_key
}

resource aws_iam_instance_profile worker {
  name = "${local.project_prefix}-worker"
  role = aws_iam_role.worker.name
}

resource aws_iam_role worker {
  name = "${local.project_prefix}-worker"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.worker_trust.json
}

data aws_iam_policy_document worker_trust {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource aws_iam_role_policy worker_s3_access {
  name = "worker-s3-access"
  role = aws_iam_role.worker.id
  policy = data.aws_iam_policy_document.worker_s3_access.json
}

data aws_iam_policy_document worker_s3_access {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.this.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}


resource aws_security_group worker {
  name        = "${local.project_prefix}-worker"
  description = "allow neccesary access for our worker"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${local.project_prefix}-worker"
  }
}

resource aws_security_group_rule allow_all {
  security_group_id = aws_security_group.worker.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule allow_ssh {
  security_group_id = aws_security_group.worker.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.worker_access_ssh_cidrs
}

resource aws_security_group_rule allow_https {
  security_group_id = aws_security_group.worker.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.worker_access_https_cidrs
}
