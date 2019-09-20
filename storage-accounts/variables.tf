variable "availability_zone" {
    type = "string"
    description = "The AZ where to create the Storage Account"
}

variable "number" {
    type = "map"
    description = "The number of storage accounts to create"

    default {
        az1 = 0,
        az2 = 0,
        az3 = 0
    }
}

variable "sequence_start" {
    default = "300"
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
