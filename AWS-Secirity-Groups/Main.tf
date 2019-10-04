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

locals {
  security_group_rulescsv = csvdecode(file("${path.module}/var.csv"))
}

resource "aws_security_group" "default" {
#count = "${length(var.functions)}"
count = length(local.security_group_rules)
name = "${format("%s_%s_SG_%s_%s", local.account_abbr, var.security_group_map[local.account_abbr], local.service_name, var.functions[count.index])}"
description = "${format("Default security group for %s - %s", local.service_name, var.functions[count.index])}"
vpc_id = "${data.aws_vpc.vpc.id}"
  type              = local.security_group_rules[count.index].type
  protocol          = local.security_group_rules[count.index].protocol
  from_port         = local.security_group_rules[count.index].from
  to_port           = local.security_group_rules[count.index].to
  cidr_blocks       = [local.security_group_rules[count.index].cidr_blocks]
  description       = local.security_group_rules[count.index].comment
  
  
}
