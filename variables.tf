variable "friendly_name_prefix" {
    type = string
    default = "BT-demo"
}

variable "vpc_id" {
    type = string
    default = "vpc-0e5a3055474dd6c40"
}

variable "subnet_id" {
    type = string  
    default = "subnet-0b65875b2ff6f28cb"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable AWS resources."
  default     = {}
}