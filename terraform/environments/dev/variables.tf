variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "terraform_module_version" {
  description = "Terraform module version"
  type        = string
  default     = "v0.4.2"
}

variable "zerotier_network_id" {
  description = "ZeroTier network ID to join."
  type        = string
}