variable project_name {
  default = "interview"
}

variable vpc_cidr {
  default = "10.0.0.0/16"
}

variable az_count {
  default = 3
}

variable global_prefix {
  default = "some_unique_global_prefix"
}

variable worker_instance_type {
  default = "t3.micro"
}

variable worker_ami_name {
  default = "amzn2-ami-hvm-2.0.20201126.0-x86_64-gp2"
}

variable worker_access_key {
  type = string
}

variable worker_access_ssh_cidrs {
  type = list(string)
}

variable worker_access_https_cidrs {
  default = ["0.0.0.0/0"]
}

locals {
  project_prefix = "${var.project_name}-${terraform.workspace}"
}
