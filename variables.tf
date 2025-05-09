# AWS Provider Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

# VPC Configuration
variable "create_vpc" {
  description = "Whether to create a new VPC (true) or use an existing one (false)"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Existing VPC ID (when create_vpc = false)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "existing_public_subnets" {
  description = "List of existing public subnet IDs (when create_vpc = false)"
  type        = list(string)
  default     = []
}

variable "existing_private_subnets" {
  description = "List of existing private subnet IDs (when create_vpc = false)"
  type        = list(string)
  default     = []
}

# EC2 Instance Configuration
variable "instance_name" {
  description = "Name of the EC2 instance running Vault"
  type        = string
  default     = "vault-server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "instance_state" {
  description = "EC2 instance state after provisioning (running or stopped)"
  type        = string
  default     = "running"
  validation {
    condition     = contains(["running", "stopped"], var.instance_state)
    error_message = "Instance state must be either 'running' or 'stopped'."
  }
}

variable "public_key" {
  description = "Path to the SSH public key file for EC2 instance access (supports ~ for home directory)"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = false
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

# Vault Configuration
variable "vault_version" {
  description = "Version of HashiCorp Vault to install"
  type        = string
  default     = "1.15.4"
}

variable "storage_backend" {
  description = "Vault storage backend (file, raft)"
  type        = string
  default     = "file"
  validation {
    condition     = contains(["file", "raft"], var.storage_backend)
    error_message = "Storage backend must be 'file' or 'raft'."
  }
}

variable "auto_unseal" {
  description = "Enable AWS KMS auto-unseal for Vault"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "AWS KMS key ID for Vault auto-unseal (required when auto_unseal = true)"
  type        = string
  default     = ""
}

variable "enable_ui" {
  description = "Enable Vault web UI"
  type        = bool
  default     = true
}

# ALB Configuration
variable "create_alb" {
  description = "Whether to create an Application Load Balancer for Vault"
  type        = bool
  default     = false
}

# Bastion Host Configuration
variable "create_bastion" {
  description = "Whether to create a bastion host"
  type        = bool
  default     = false
}

variable "bastion_instance_name" {
  description = "Name of the bastion EC2 instance"
  type        = string
  default     = "bastion-host"
}

variable "bastion_instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_public_key" {
  description = "Path to the SSH public key file for bastion host access (supports ~ for home directory)"
  type        = string
  default     = ""
}

variable "bastion_volume_size" {
  description = "Size of the root volume in GB for bastion host"
  type        = number
  default     = 10
}

# General
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'staging', or 'prod'."
  }
}

# User Data Scripts
variable "custom_vault_user_data" {
  description = "Custom user data script for the Vault server. If provided, this will override the default Vault installation script."
  type        = string
  default     = ""
}

variable "custom_bastion_user_data" {
  description = "Custom user data script for the bastion host. This is optional as the bastion host doesn't use the default Vault script."
  type        = string
  default     = ""
}

variable "enable_vault_user_data" {
  description = "Whether to enable the default Vault installation script for the Vault server."
  type        = bool
  default     = true
}
