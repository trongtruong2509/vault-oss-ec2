output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "vault_instance_id" {
  description = "ID of the Vault EC2 instance"
  value       = module.ec2_vault.vault_instance_id
}

output "vault_private_ip" {
  description = "Private IP address of the Vault instance"
  value       = module.ec2_vault.vault_private_ip
}

output "vault_public_ip" {
  description = "Public IP address of the Vault instance (if applicable)"
  value       = module.ec2_vault.vault_public_ip
}

output "vault_endpoint" {
  description = "Vault API endpoint"
  value       = module.ec2_vault.vault_endpoint
}

# Bastion host outputs
output "bastion_instance_id" {
  description = "ID of the Bastion EC2 instance"
  value       = var.create_bastion ? module.ec2_bastion[0].vault_instance_id : null
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion instance"
  value       = var.create_bastion ? module.ec2_bastion[0].vault_public_ip : null
}

output "bastion_private_ip" {
  description = "Private IP address of the Bastion instance"
  value       = var.create_bastion ? module.ec2_bastion[0].vault_private_ip : null
}

output "ssh_to_bastion" {
  description = "SSH command to connect to the Bastion host"
  value       = var.create_bastion ? "ssh ubuntu@${module.ec2_bastion[0].vault_public_ip}" : null
}
