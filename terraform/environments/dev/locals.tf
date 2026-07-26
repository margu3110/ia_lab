locals {
  project_name = "ia-lab"
  environment  = "dev"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "Marcelo"
    Repository  = "ia_lab"
  }
}