module "networking" {
  source = "git::ssh://git@github.com/margu3110/terraform-aws-modules.git//modules/networking?ref=v0.4.3"

  name = local.project_name

  vpc_cidr = "10.50.0.0/16"

  public_subnet_cidrs = [
    "10.50.1.0/24",
    "10.50.2.0/24"
  ]

  tags = local.common_tags
}

module "security_group" {
  source = "git::ssh://git@github.com/margu3110/terraform-aws-modules.git//modules/security_group?ref=v0.4.3"

  name        = "${local.project_name}-sg"
  description = "Security group for IA Lab"

  vpc_id = module.networking.vpc_id

  # ingress_rules = {
  #   ssh = {
  #     description = "SSH access"

  #     from_port = 22
  #     to_port   = 22

  #     ip_protocol = "tcp"

  #     cidr_ipv4 = "0.0.0.0/0"
  #   }
  # }

  egress_rules = {
    internet = {
      description = "Internet access"

      from_port = 0
      to_port   = 0

      ip_protocol = "-1"

      cidr_ipv4 = "0.0.0.0/0"
    }
  }

  tags = local.common_tags
}

module "iam" {
  source = "git::ssh://git@github.com/margu3110/terraform-aws-modules.git//modules/iam?ref=v0.4.3"

  name = local.project_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = local.common_tags
}

module "ec2_spot" {
  source = "git::ssh://git@github.com/margu3110/terraform-aws-modules.git//modules/ec2_spot?ref=v0.4.3"

  name = local.project_name

  instance_type = "t3.large"

  subnet_id = module.networking.public_subnet_ids[0]

  security_group_ids = [
    module.security_group.security_group_id
  ]

  instance_profile_name = module.iam.instance_profile_name

  user_data = file("${path.root}/../../../scripts/bootstrap.sh")

  tags = local.common_tags
}

module "ollama" {
  source = "git::ssh://git@github.com/margu3110/terraform-aws-modules.git//modules/ollama?ref=v0.4.3"

  instance_id = module.ec2_spot.instance_id

  tags = local.common_tags
}

module "zerotier" {
  source = "git::ssh://git@github.com/margu3110/terraform-aws-modules.git//modules/zerotier?ref=v0.4.3"

  instance_id = module.ec2_spot.instance_id
}