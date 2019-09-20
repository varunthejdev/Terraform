data "aws_caller_identity" "current" {}

locals {
  account_abbr = "${substr(data.aws_caller_identity.current.account_id, -4, -1)}"
  service_name = "${substr(terraform.workspace, 5, -1)}"
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["${format("%s_%s_VPC", local.account_abbr, var.security_group_map[local.account_abbr])}"]
  }
}

resource "aws_security_group" "default" {
  count = "${length(var.functions)}"

  name = "${format("%s_%s_SG_%s_%s", local.account_abbr, var.security_group_map[local.account_abbr], local.service_name, var.functions[count.index])}"
  description = "${format("Default security group for %s - %s", local.service_name, var.functions[count.index])}"
  vpc_id = "${data.aws_vpc.vpc.id}"

  ingress {
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic"
  }

  egress {
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic"
  }
}
