<div align="right">

**English** | [中文](README-CN.md)

</div>

# Landing Zone Accelerator

## Project Overview

Landing Zone Accelerator is a Terraform-based Alibaba Cloud Landing Zone solution accelerator. It provides a set of standardized Infrastructure as Code (IaC) templates to help enterprises quickly build and manage multi-account environments on Alibaba Cloud, achieving secure, compliant, and efficient cloud resource management.

## Architecture Layers

The project adopts a three-layer architecture design, from bottom to top:

### 1. Module Layer

The bottommost fine-grained modules, typically abstracted as a Module when meeting the following conditions:

- Responsible for creation and configuration of a single product
- Uses >= 2 Terraform Resources or Datasources

**Main modules include:**
- Network modules: VPC, NAT Gateway, EIP, PrivateZone, CEN VPC Attachment, CEN Bandwidth Package, Common Bandwidth Package, DMZ VPC Egress, Security Group
- Security modules: KMS Instance, Security Group
- Logging modules: SLS Project, SLS Logstore, OSS Bucket
- Identity modules: CloudSSO Users and Groups
- Monitoring modules: CMS Service, CMS Alarm Contact
- Configuration modules: Config Configuration Recorder, Tag Policy

### 2. Component Layer

Component can be considered a higher-dimensional Module, developed in the same way as Terraform Modules. Landing Zone functional modules or sub-modules can be abstracted as a Component.

**Abstraction Principles:**

- **Identity dependency relationships exist**: For example, in Account Factory, configuring account baseline requires creating an account first, then using the new account's identity to configure the baseline, so it must be divided into two Components:
  - `account`: Create new account
  - `baseline`: Configure account baseline

- **Independent sub-functional modules**: For example, the Landing Zone compliance audit module, which can be divided into protection rules and log delivery sub-functions, can be abstracted as multiple Components:
  - `guardrails`: Protection rules, involving Config Rule and Control Policy, can be further split into:
    - `detective`: Detective protection rules, Config Rule
    - `preventive`: Preventive protection rules, Control Policy
  - `log-archive`: Log delivery, involving ActionTrail and Config Audit, can be further split into:
    - `actiontrail`: ActionTrail log delivery
    - `config`: Config Audit log delivery
    - `log-audit`: Log audit

**Main components include:**

- **Resource Structure**
  - `folders`: Create resource directory and hierarchical folder structure
  - `accounts`: Create functional accounts and configure service delegation administrators

- **Account Factory**
  - `account`: Create member accounts
  - `baseline`: Configure account baseline (contact, preset-tag, ram-role, ram-security-preference, ram-user, security-group, vpc-baseline)

- **Identity Management**
  - `cloudsso`: CloudSSO configuration, including service activation, access configuration creation, user and group management

- **Network**
  - `cen-instance`: Cloud Enterprise Network instance
  - `cen-transit-router`: CEN Transit Router
  - `cen-route-map`: CEN route map
  - `cen-tr-inter-region-connection`: CEN Transit Router inter-region connection
  - `cen-vpn-connection`: CEN VPN connection
  - `dmz`: DMZ network zone configuration

- **Security**
  - `bastion-host`: Bastion Host instance
  - `cloud-firewall`: Cloud Firewall instance, member account management, internet boundary protection rules
  - `kms`: KMS instance management
  - `security-center`: Security Center configuration
  - `wafv3`: WAFv3 instance, protection templates and rule configuration

- **Compliance Audit (Guardrails)**
  - `detective`: Config Audit rules, compliance package management
  - `preventive`: Resource Manager control policies

- **Log Archive**
  - `actiontrail`: ActionTrail log delivery to OSS/SLS
  - `config`: Config Audit log delivery to OSS/SLS
  - `log-audit`: Log audit policy configuration

## Main Functional Modules

### Resource Structure

- Create and manage resource directory
- Create hierarchical folder structure (up to 5 levels)
- Create functional accounts (supports Trustee and Self-Pay billing)
- Configure service delegation administrators

### Account Factory

- Create member accounts
- Configure account baseline (contact, preset tag, RAM role, RAM security preference, RAM user, security group, VPC baseline)

### Identity Management

- CloudSSO service activation and configuration
- Create access configurations (supports system management and custom policies)
- User and group management
- Multi-account access permission assignment

### Network

- Cloud Enterprise Network (CEN) instance, Transit Router, route map, inter-region connection, VPN connection
- DMZ network zone configuration
- Inter-VPC connectivity

### Security

- Bastion Host instance management
- Cloud Firewall centralized deployment and multi-account management
- KMS key management service
- Security Center configuration
- WAFv3 Web Application Firewall

### Compliance Audit (Guardrails)

- Config Audit rules and compliance packages
- Resource Manager control policies
- Supports template-based rules and custom Function Compute rules

### Log Archive

- ActionTrail log delivery (OSS/SLS)
- Config Audit log delivery (OSS/SLS)
- Log audit policy configuration

## Usage

### Prerequisites

- Terraform >= 0.13
- Alibaba Cloud Terraform Provider >= 1.262.1
- Alibaba Cloud account and appropriate permissions

### Usage Modes

This project supports two usage modes, choose based on actual requirements:

#### Mode 1: Self-Built CI/CD Pipeline

If building your own CI/CD pipeline and Terraform runtime, you can directly reference Components for deployment:

```hcl
module "folders" {
  source = "./components/resource-structure/folders"

  folder_structure = [
    {
      folder_name        = "Core"
      parent_folder_name = null
      level              = 1
    },
    {
      folder_name        = "Production"
      parent_folder_name = null
      level              = 1
    }
  ]
}
```

**Advantages:**
- Complete control over deployment process
- Flexible integration with existing CI/CD systems
- Customizable deployment logic based on requirements

## Testing

The project includes test configurations for all components, located in the `test/` directory, which can be used to verify component functionality.

### Test Structure

- `test/components/`: Component tests

### Testing Steps

1. **Navigate to test directory**

   ```bash
   cd test/components/<component-name>
   ```

2. **Configure Alibaba Cloud credentials**

   ```bash
   export ALICLOUD_ACCESS_KEY="your-access-key"
   export ALICLOUD_SECRET_KEY="your-secret-key"
   export ALICLOUD_REGION="cn-hangzhou"
   ```

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

4. **Review execution plan**

   ```bash
   terraform plan
   ```

5. **Apply configuration (create resources)**

   ```bash
   terraform apply
   ```

6. **Clean up resources (after testing)**

   ```bash
   terraform destroy
   ```

## Directory Structure

```
.
├── modules/              # Module layer: fine-grained modules
├── components/           # Component layer: functional components
└── test/                 # Test code
    └── components/       # Component tests
```

**Key Directory Descriptions:**

- **modules/**: Contains the most basic fine-grained modules, each module corresponds to specific cloud resources or functions
- **components/**: Functional components formed by combining multiple modules, implementing more complex business functions
- **test/**: Contains test configurations for components, used to verify component functionality

## Notes

### General Notes

- This project is based on Alibaba Cloud Terraform Provider
- Requires Alibaba Cloud account and appropriate permissions
- Recommend validating in test environment before deploying to production
- Testing will create actual cloud resources, please be aware of associated costs
- Some resource creation may take considerable time (e.g., account creation)
- Ensure required cloud services are activated (e.g., Resource Manager, CloudSSO, etc.)
- Please read each component's README documentation before use to understand detailed configuration parameters and constraints

## Related Documentation

- **Component Documentation**: Detailed documentation for each Component can be found in `components/<component-name>/README.md`
- **Module Documentation**: Detailed documentation for each Module can be found in `modules/<module-name>/README.md`

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.