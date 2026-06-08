###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token"
}

variable "cloud_id" {
  type        = string
  description = "Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Folder ID"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Default availability zone"
}

variable "vpc_name" {
  type        = string
  default     = "network-hw"
  description = "VPC network name"
}

variable "public_subnet_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
}

variable "private_subnet_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
}

variable "nat_image_id" {
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
  description = "NAT instance image ID"
}
