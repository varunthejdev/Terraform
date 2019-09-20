variable "functions" {
  # type = list(string)
  type = "list"
  description = "List of functions to create Security Groups for"
}

variable "resource_group_map" {
  # type = map(string)
  type = "map"
  description = "Mapping of subscription ID to logical name for Resource Groups"

  default {
      "1212" = "PAD"
    "2343" = "SHEFFIELD"
    "v151" = "LONDON"
    "2866" = "PRASA"
    "434c" = "Petert"
    "b789" = "ioc" # This one for testing
    "q012" = "SAAS"
    "314h" = "engle"
  }
}

variable "network_security_group_map" {
  # type = map(string)
  type = "map"
  description = "Mapping of subscription ID to logical name for Network Security Groups"

  default {
      "1212" = "PAD"
    "2343" = "SHEFFIELD"
    "v151" = "LONDON"
    "2866" = "PRASA"
    "434c" = "Petert"
    "b789" = "ioc" # This one for testing
    "q012" = "SAAS"
    "314h" = "engle"
  }
}

# variable "inbound_rules" {
#   type = "list"
#   description = "List of inbound rules"

#   default = [
#     {
#       name = "AllowAnyInbound"
#       priority = 100
#       direction = "Inbound"
#       access = "Allow"
#       protocol = "*"
#       source_port_range = "*"
#       destination_port_range = "*"
#       source_address_prefix = "*"
#       destination_address_prefix = "*"
#     }
#   ]
# }

# variable "outbound_rules" {
#   type = "list"
#   description = "List of outbound rules"

#   default = [
#     {
#       name = "AllowAnyOutbound"
#       priority = 100
#       direction = "Outbound"
#       access = "Allow"
#       protocol = "*"
#       source_port_range = "*"
#       destination_port_range = "*"
#       source_address_prefix = "*"
#       destination_address_prefix = "*"
#     }
#   ]
# }
