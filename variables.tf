variable "tags" {
  type = map(string)
  default = {
    ManagedBy = "Terraform"
    Owner     = "Hien"
  }
}

variable "VM_Size" {
  type = map(string)
  default = {
    Web = "Standard_D2s_v3"
    DB  = "Standard_D2s_v3"
  }
}

variable "OS_DISK_Size" {
  type = map(number)
  default = {
    Web = 20
    DB  = 30
  }
}

variable "ENV" {
  type = map(string)
  default = {
    PROD = "PRD"
    DEV  = "DEV"
    STG  = "STG"
  }
}

variable "New" {
  type = string
  default = "value"
}