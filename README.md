# Vault OSS EC2 Infrastructure

This Terraform configuration provisions a HashiCorp Vault OSS server on AWS EC2. The server will be automatically installed and configured with initial settings.

## Prerequisites

- AWS credentials with appropriate permissions
- Terraform installed (>= 1.0.0)
- Existing VPC with subnets (optional)

## Usage

1. Create your `terraform.tfvars` file in the root folder. You can refer to `terraform.tfvars.example` as a template, but make sure to replace all placeholder values with your actual configuration.

2. Configure the variables in `terraform.tfvars`, ensuring to provide:
   - AWS credentials
   - VPC and subnet IDs (or set create_vpc = true to create a new VPC)
   - SSH public key (optional)
   - Vault configuration options
   - Custom user data scripts (optional)

3. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply --auto-approve
   ```

**Note:** The terraform apply process will take approximately 5-7 minutes as it:
- Provisions the VPC (if specified)
- Provisions the EC2 instance
- Installs and configures Vault OSS
- Sets up basic Vault configuration

## Auto-Unseal Configuration

This module supports AWS KMS auto-unseal for Vault in two ways:

1. **Using an existing KMS key**:
   ```hcl
   auto_unseal = true
   kms_key_id  = "your-existing-kms-key-id"
   ```

2. **Automatic KMS key creation**:
   ```hcl
   auto_unseal = true
   # Leave kms_key_id empty to auto-create a new KMS key
   ```

When `auto_unseal = true` and `kms_key_id` is empty, the module will automatically:
- Create a new AWS KMS key with proper permissions
- Configure Vault to use this key for auto-unsealing
- Output the key ID and alias for future reference

This feature makes it simple to set up Vault with auto-unsealing without having to manually create KMS keys first.

## User Data Script Management

This module provides completely externalized user data script handling:

- **Vault Server**: 
  - User data is prepared in the root module
  - The default script at `scripts/user_data.sh.tftpl` is used by default
  - You can disable it entirely by setting `enable_vault_user_data = false`
  - Or provide your own custom script with `custom_vault_user_data`

- **Bastion Host**:
  - No user data script by default
  - Optionally provide initialization script with `custom_bastion_user_data`

This flexible approach allows you to:
1. Use the default Vault installation script
2. Provide your own custom script
3. Create instances with no user data script at all

## Important Notes

- If creating a new VPC, the process will set up public and private subnets with proper routing
- If using an existing VPC, ensure the subnets have proper internet connectivity
- After initial provisioning, you'll need to initialize Vault manually
- Remember to securely store the initial root token and unseal keys
- Vault will be accessible on port 8200

## Accessing Vault

1. Start the EC2 instance (if it's stopped)
2. Access Vault using: `https://<instance-ip>:8200` or via the ALB if configured
3. Initialize Vault if needed with:
   ```bash
   vault operator init
   ```
4. If using auto-unseal, Vault will automatically unseal when restarted

## Bastion Host

For enhanced security, you can optionally deploy a bastion host as the sole entry point to your Vault server:

1. Set `create_bastion = true` in your terraform.tfvars
2. Configure bastion parameters:
   ```hcl
   bastion_instance_name = "bastion-host"
   bastion_instance_type = "t3.micro"
   bastion_public_key    = "/path/to/your/key.pub"
   bastion_volume_size   = 10
   ```
3. After provisioning, you can SSH to the bastion host and then to your Vault server

## Security Considerations

- This setup is intended for development or testing purposes
- For production, consider:
  - Using AWS KMS for auto-unseal (supported natively by this module)
  - Setting up proper TLS certificates
  - Implementing Vault HA configuration
  - Using a more robust storage backend like DynamoDB
  - Restricting KMS key policy (the default policy is permissive)

## Input Variables

Please see the variables.tf files in each module for detailed information about available configuration options.

## Outputs

Key outputs from this module:

| Name | Description |
|------|-------------|
| vault_endpoint | The endpoint URL to access Vault |
| vault_instance_id | The EC2 instance ID of Vault server |
| vault_public_ip | The public IP of Vault server (if enabled) |
| vault_auto_unseal_kms_key_id | The KMS key ID used for auto-unsealing (if created) |
| vault_auto_unseal_kms_key_alias | The KMS key alias used for auto-unsealing (if created) |
