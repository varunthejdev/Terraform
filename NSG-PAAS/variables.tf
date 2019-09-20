variable "nsgs" {
  # type = list(string)
  type = "list"
  description = "List of NSGs to createZ"
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
