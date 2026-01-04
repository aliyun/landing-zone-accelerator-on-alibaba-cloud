<div align="right">

**中文** | [English](README.md)

</div>

# Landing Zone Accelerator

## 项目概述

Landing Zone Accelerator 是一个基于 Terraform 的阿里云 Landing Zone 解决方案加速器。它提供了一套标准化的基础设施即代码 (IaC) 模板，帮助企业快速构建和管理阿里云上的多账号环境，实现安全、合规和高效的云资源管理。

## 架构层次

项目采用三层架构设计，从下往上分别为：

### 1. Module（模块）层

最底层的细粒度模块，通常满足以下条件才被抽象为一个 Module：

- 负责单个产品的创建和配置
- 使用到的 Terraform Resource 或 Datasource 数量 >= 2

**主要模块包括：**
- 网络模块：VPC、NAT 网关、EIP、PrivateZone、CEN VPC 连接、DMZ VPC 出网
- 安全模块：KMS 实例、WAFv3 实例/模板/规则、RAM 角色、RAM 安全偏好设置
- 日志模块：SLS Project、SLS Logstore、OSS Bucket
- 身份模块：CloudSSO 用户和组
- 监控模块：CMS、Contact
- 配置模块：Config Configuration Recorder、Preset Tag

### 2. Component（组件）层

Component 可以认为是更高维度的 Module，开发方式和 Terraform Module 的方式一样。Landing Zone 的功能模块或子模块可以抽象为一个 Component。

**抽象划分原则：**

- **在调用身份上存在依赖关系**：比如账号工厂，配置账号基线的前提是需要先创建出账号，用新建账号的身份配置基线，因此必须划分为两个 Component：
  - `account`：新建账号
  - `baseline`：配置账号基线

- **相互无关的子功能模块**：比如 Landing Zone 合规审计模块，可以分为防护规则和日志投递两部分子功能，就可以抽象为多个 Component：
  - `guardrails`：防护规则，涉及 Config Rule 和 Control Policy，因此又可以拆分为：
    - `detective`：发现型防护规则，Config Rule
    - `preventive`：预防型防护规则，Control Policy
  - `log-archive`：日志投递，涉及操作审计和配置审计，因此又可以拆分为：
    - `actiontrail`：操作审计日志投递
    - `config`：配置审计日志投递
    - `log-audit`：日志审计

**主要组件包括：**

- **资源结构 (Resource Structure)**
  - `folders`：创建资源目录和分层文件夹结构
  - `accounts`：创建功能账号并配置服务委托管理员

- **账号工厂 (Account Factory)**
  - `account`：创建成员账号
  - `baseline`：配置账号基线

- **身份管理 (Identity)**
  - `cloudsso`：CloudSSO 配置，包括开通服务、创建访问配置、用户和组管理

- **网络 (Network)**
  - `cen`：云企业网实例和转发路由器
  - `dmz`：DMZ 网络区域配置

- **安全 (Security)**
  - `bastion-host`：堡垒机实例
  - `cloud-firewall`：云防火墙实例、成员账号管理、互联网边界防护规则
  - `kms`：KMS 实例管理
  - `security-center`：云安全中心配置
  - `wafv3`：WAFv3 实例、防护模板和规则配置

- **合规审计 (Guardrails)**
  - `detective`：配置审计规则、合规包管理
  - `preventive`：资源管理控制策略

- **日志归档 (Log Archive)**
  - `actiontrail`：操作审计日志投递到 OSS/SLS
  - `config`：配置审计日志投递到 OSS/SLS
  - `log-audit`：日志审计策略配置

## 主要功能模块

### 资源结构 (Resource Structure)

- 创建和管理资源目录
- 创建分层文件夹结构（最多 5 层）
- 创建功能账号（支持财务托管和自主结算）
- 配置服务委托管理员

### 账号工厂 (Account Factory)

- 创建成员账号
- 配置账号基线（RAM 角色、安全偏好等）

### 身份管理 (Identity)

- CloudSSO 服务开通和配置
- 创建访问配置（支持系统管理和自定义策略）
- 用户和组管理
- 多账号访问权限分配

### 网络 (Network)

- 云企业网 (CEN) 实例和转发路由器
- DMZ 网络区域配置
- VPC 间互联

### 安全 (Security)

- 堡垒机实例管理
- 云防火墙中心化部署和多账号管理
- KMS 密钥管理服务
- 云安全中心配置
- WAFv3 Web 应用防火墙

### 合规审计 (Guardrails)

- 配置审计规则和合规包
- 资源管理控制策略
- 支持基于模板的规则和自定义 Function Compute 规则

### 日志归档 (Log Archive)

- 操作审计日志投递（OSS/SLS）
- 配置审计日志投递（OSS/SLS）
- 日志审计策略配置

## 使用方法

### 前置要求

- Terraform >= 0.13
- Alibaba Cloud Terraform Provider >= 1.262.1
- 阿里云账号和相应权限

### 使用方式
引用 Components 进行部署：

``hcl
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

## 测试方法

项目中包含了各组件的测试配置，位于 `test/` 目录下，可以用于验证组件的功能。

### 测试结构

- `test/components/`：组件测试

### 测试步骤

1. **进入测试目录**

   ```bash
   cd test/components/<component-name>
   ```

2. **配置阿里云认证信息**

   ```bash
   export ALICLOUD_ACCESS_KEY="your-access-key"
   export ALICLOUD_SECRET_KEY="your-secret-key"
   export ALICLOUD_REGION="cn-hangzhou"
   ```

3. **初始化 Terraform**

   ```bash
   terraform init
   ```

4. **查看执行计划**

   ```bash
   terraform plan
   ```

5. **应用配置（创建资源）**

   ```bash
   terraform apply
   ```

6. **清理资源（测试完成后）**

   ```bash
   terraform destroy
   ```

## 目录结构

```
.
├── modules/              # Module 层：细粒度模块
├── components/           # Component 层：功能组件
└── test/                 # 测试代码
    └── components/       # 组件测试
```

**关键目录说明：**

- **modules/**：包含最基础的细粒度模块，每个模块对应特定的云资源或功能
- **components/**：由多个module组合成功能组件，实现了更复杂的业务功能
- **test/**：包含各组件的测试配置，用于验证组件功能

## 注意事项

### 通用注意事项

- 该项目基于阿里云 Terraform Provider
- 需要具备阿里云账号和相应权限
- 建议在测试环境中先行验证再部署到生产环境
- 测试时会产生实际的云资源，请注意相关费用
- 部分资源创建可能需要较长时间（如账号创建）
- 确保已开通所需云服务（如 Resource Manager、CloudSSO 等）
- 使用前请仔细阅读各组件的 README 文档，了解详细的配置参数和约束条件

## 相关文档

- **组件文档**：各 Component 的详细文档请参考 `components/<component-name>/README-CN.md`
- **模块文档**：各 Module 的详细文档请参考 `modules/<module-name>/README-CN.md`

## 许可证

本项目采用 Apache License 2.0 许可证。详情请参阅 [LICENSE](LICENSE) 文件。