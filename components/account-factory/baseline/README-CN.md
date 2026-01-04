<div align="right">

**中文** | [English](README.md)

</div>

# Account Factory Baseline

此目录作为账号基线配置的参考。它不包含可重用的组件模块，而是记录了账号工厂部署中使用的基线配置模式。

## 概述

账号基线配置包括需要部署到新创建的成员账号的各种基础设施组件，例如：

- 预设标签
- 联系信息
- RAM 安全偏好设置
- RAM 角色
- VPC 网络
- 私有 DNS 区域
- 云监控服务（CMS）配置

## 为什么不是组件？

**此基线配置无法封装为可重用的组件模块**，原因如下：

1. **不同的 Provider 配置**：每个基线项可能需要不同的 provider 配置：
   - 某些模块使用默认 provider（例如 `preset_tags`、`contact`、`ram_security_preference`）
   - 某些模块需要特定区域的 VPC provider（例如 `vpc`、`private_zone`）
   - 每个 provider 可能需要承担不同的角色或使用不同的区域

2. **Provider 别名**：基线配置使用多个 provider 别名：
   - `provider.alicloud.default` - 大多数资源的默认 provider
   - `provider.alicloud.vpc` - VPC 特定的 provider（可能使用不同的区域）

3. **跨组件依赖**：某些组件依赖于其他组件的输出：
   - `private_zone` 依赖于 `vpc.vpc_id`
   - 组件需要明确的 `depends_on` 关系

4. **灵活配置**：不同账号可能需要不同的基线配置，这使得创建通用组件变得不切实际。

## 实现模式

基线配置不是组件模块，而是通过跨账号角色扮演方式到目标账号中创建所需资源，需要在上层业务代码中中Provider中进行定义跨账号角色扮演的信息，并引用models中的基线组件进行资源创建。

## 基线组件

典型的基线包括以下模块：

| Component | Module Source | Provider | Description |
|-----------|--------------|----------|-------------|
| `preset_tags` | `modules/preset-tag` | `default` | 资源的预设标签 |
| `contact` | `modules/contact` | `default` | 账号联系信息 |
| `ram_security_preference` | `modules/ram-security-preference` | `default` | RAM 安全设置 |
| `ram_roles` | `modules/ram-role` | `default` | RAM 角色（for_each） |
| `vpc` | `modules/vpc` | `vpc` | VPC 网络配置 |
| `private_zone` | `modules/private-zone` | `vpc` | 私有 DNS 区域 |
| `cms` | `modules/cms` | `default` | 云监控服务 |

## 注意事项

- 每个基线组件都是可以独立配置的独立模块
- Provider 配置必须匹配每个模块的要求
- 使用 `depends_on` 确保正确的资源创建顺序
- 基线配置假设账号具有 `ResourceDirectoryAccountAccessRole` 角色以进行跨账号访问
- VPC 和 Private Zone 组件使用单独的 provider 以支持不同的区域