<div align="right">

**English** | [中文](README-CN.md)

</div>

# Account Factory Baseline

This directory serves as a reference for account baseline configurations. It does not contain reusable component modules, but rather documents the baseline configuration patterns used in account factory deployments.

## Overview

Account baseline configurations include various infrastructure components that need to be deployed to newly created member accounts, such as:

- Preset tags
- Contact information
- RAM security preferences
- RAM roles
- VPC networks
- Private DNS zones
- Cloud Monitor Service (CMS) configurations

## Why Not a Component?

**This baseline configuration cannot be encapsulated as a reusable component module** for the following reasons:

1. **Different Provider configurations**: Each baseline item may require different provider configurations:
   - Some modules use the default provider (e.g., `preset_tags`, `contact`, `ram_security_preference`)
   - Some modules require a specific VPC region provider (e.g., `vpc`, `private_zone`)
   - Each provider may need to assume different roles or use different regions

2. **Provider aliases**: The baseline configuration uses multiple provider aliases:
   - `provider.alicloud.default` - Default provider for most resources
   - `provider.alicloud.vpc` - VPC-specific provider (may use different regions)

3. **Cross-component dependencies**: Some components depend on outputs from other components:
   - `private_zone` depends on `vpc.vpc_id`
   - Components require explicit `depends_on` relationships

4. **Flexible configuration**: Different accounts may require different baseline configurations, making it impractical to create a generic component.

## Implementation Pattern

Rather than being a component module, the baseline configuration creates required resources in the target account through cross-account role assumption. Cross-account role assumption information needs to be defined in the Provider in the upper-level business code, and baseline components from models are referenced for resource creation.

## Baseline Components

A typical baseline includes the following modules:

| Component | Module Source | Provider | Description |
|-----------|--------------|----------|-------------|
| `preset_tags` | `modules/preset-tag` | `default` | Preset tags for resources |
| `contact` | `modules/contact` | `default` | Account contact information |
| `ram_security_preference` | `modules/ram-security-preference` | `default` | RAM security settings |
| `ram_roles` | `modules/ram-role` | `default` | RAM roles (for_each) |
| `vpc` | `modules/vpc` | `vpc` | VPC network configuration |
| `private_zone` | `modules/private-zone` | `vpc` | Private DNS zones |
| `cms` | `modules/cms` | `default` | Cloud Monitor Service |


## Considerations

- Each baseline component is an independent module that can be configured separately
- Provider configurations must match the requirements of each module
- Use `depends_on` to ensure correct resource creation order
- Baseline configurations assume the account has the `ResourceDirectoryAccountAccessRole` role for cross-account access
- VPC and Private Zone components use separate providers to support different regions