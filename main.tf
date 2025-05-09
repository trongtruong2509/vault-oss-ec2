terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  # VPC specific variables
  environment              = var.environment
  create_vpc               = var.create_vpc
  vpc_id                   = var.vpc_id
  vpc_cidr                 = var.vpc_cidr
  existing_public_subnets  = var.existing_public_subnets
  existing_private_subnets = var.existing_private_subnets
}

# Prepare user data for Vault server
locals {
  # Generate user data for Vault server if needed
  vault_user_data = var.custom_vault_user_data != "" ? var.custom_vault_user_data : (
    var.enable_vault_user_data ? templatefile("${path.root}/scripts/user_data.sh.tftpl", {
      vault_version    = var.vault_version
      storage_backend  = var.storage_backend
      auto_unseal      = var.auto_unseal
      kms_key_id       = var.kms_key_id
      enable_ui        = var.enable_ui
      enable_public_ip = var.associate_public_ip_address
    }) : ""
  )

  # Bastion user data (optional)
  bastion_user_data = var.custom_bastion_user_data
}

# EC2 Vault Module
module "ec2_vault" {
  source = "./modules/ec2"

  # Environment variables
  environment = var.environment

  # EC2 specific variables
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = var.create_vpc ? module.vpc.public_subnets[0] : var.existing_public_subnets[0]
  instance_name               = var.instance_name
  instance_type               = var.instance_type
  instance_state              = var.instance_state
  public_key                  = var.public_key
  associate_public_ip_address = var.associate_public_ip_address
  volume_size                 = var.volume_size
  security_group_name         = "vault-server-sg"

  # User data - prepared outside the module
  user_data = local.vault_user_data

  # ALB configuration
  create_alb        = var.create_alb
  public_subnet_ids = var.create_vpc ? module.vpc.public_subnets : var.existing_public_subnets
}

# Bastion Host Module
module "ec2_bastion" {
  source = "./modules/ec2"
  count  = var.create_bastion ? 1 : 0

  # Environment variables
  environment = var.environment

  # EC2 specific variables
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = var.create_vpc ? module.vpc.public_subnets[0] : var.existing_public_subnets[0]
  instance_name               = var.bastion_instance_name
  instance_type               = var.bastion_instance_type
  instance_state              = "running"
  public_key                  = var.bastion_public_key
  associate_public_ip_address = true
  volume_size                 = var.bastion_volume_size
  security_group_name         = "bastion-sg" # Unique security group name

  # User data - prepared outside the module (may be empty)
  user_data = local.bastion_user_data

  # ALB configuration - no ALB for bastion
  create_alb        = false
  public_subnet_ids = []
}
