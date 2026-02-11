<div align="right">

**中文** | [English](README.md)

</div>

# Log Audit 组件

该组件用于创建和管理阿里云 SLS（日志服务）日志审计采集策略，实现从各种云产品的集中式日志采集。

## 功能特性

- 创建 SLS 项目用于日志存储
- 为采集策略创建日志库
- 为各种云产品创建采集策略
- 支持通过资源目录进行多账号采集
- 配置集中式日志传输到 SLS
- 支持不同的资源采集模式（all、attributeMode、instanceMode）

## 重要说明

### Provider 地域限制

使用 `alicloud.log_audit` provider 时，**region 只能设置为以下两个地域之一**：
- 华东 2（上海）：`cn-shanghai`
- 新加坡：`ap-southeast-1`

这是因为阿里云 SLS 日志审计服务目前只支持这两个地域。

### 地域限制影响说明

- **Provider 地域限制**：仅影响 `alicloud.log_audit` provider 的配置
- **Project 地域**：不受影响，可以在任何支持的地域创建 SLS Project
- **日志采集范围**：可以采集其他云产品在全地域的日志，不受此限制

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |
| random | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.log_audit | >= 1.267.0（region 必须是 `cn-shanghai` 或 `ap-southeast-1`） |
| alicloud.sls_project | >= 1.267.0 |
| random | >= 3.1.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| sls_project | ../../../modules/sls-project | 日志存储的 SLS 项目 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_log_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_service) | data source | 日志服务开通 |
| [alicloud_log_projects.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_projects) | data source | 当前 SLS 项目查询 |
| [alicloud_log_store.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store) | resource | 采集策略的日志库 |
| [alicloud_sls_collection_policy.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sls_collection_policy) | resource | 云产品的采集策略 |

## 使用方法

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit  # 必须使用 cn-shanghai 或 ap-southeast-1
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "log-audit-project"
  create_project = true

  collection_policies = [
    {
      policy_name  = "ecs-audit"
      product_code = "ecs"
      enabled      = true
      data_code    = "audit_log"
      policy_config = {
        resource_mode = "all"
        instance_ids  = null
        regions       = null
        resource_tags = null
      }
      logstore = {
        create            = true
        retention_period  = 180
        shard_count       = 2
        auto_split        = true
        max_split_shard_count = 64
      }
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `project_name` | 目标 SLS 项目名称 | `string` | - | Yes | 3-63 个字符，以小写字母或数字开头和结尾 |
| `create_project` | 是否创建 SLS 项目 | `bool` | `false` | No | - |
| `project_description` | 创建 SLS 项目时的描述 | `string` | `null` | No | - |
| `project_tags` | 创建 SLS 项目时的标签 | `map(string)` | `null` | No | - |
| `append_random_suffix` | 是否在项目名称后追加随机后缀 | `bool` | `false` | No | 仅在 `create_project = true` 时 |
| `random_suffix_length` | 随机后缀长度 | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | 项目名称和后缀之间的分隔符 | `string` | `"-"` | No | 必须是：`"-"`、`"_"` 或 `""` |
| `collection_policies` | 要创建的采集策略列表 | `list(object)` | `[]` | No | 参见采集策略结构 |

### 采集策略对象结构

`collection_policies` 中每个策略必须具有以下结构：

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `policy_name` | `string` | - | Yes | 策略名称 | 3-63 个字符，以字母开头，仅包含 [a-z0-9_-] |
| `product_code` | `string` | - | Yes | 产品代码 | 参见阿里云文档 |
| `enabled` | `bool` | - | Yes | 策略是否启用 | - |
| `data_code` | `string` | - | Yes | 日志类型编码 | 参见阿里云文档 |
| `policy_config` | `object` | - | Yes | 策略配置 | 参见 policy_config 结构 |
| `data_config` | `object` | `null` | No | 数据配置 | 特定 product_code/data_code 组合需要 |
| `resource_directory` | `object` | 见下方 | No | 资源目录配置 | - |
| `logstore` | `object` | - | Yes | 日志库配置 | 参见 logstore 结构 |

#### Policy Config 对象结构

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `resource_mode` | `string` | - | Yes | 资源采集模式 | 必须是：`all`、`attributeMode` 或 `instanceMode` |
| `instance_ids` | `list(string)` | `null` | No | 要采集的实例 ID | 当 `resource_mode = "instanceMode"` 时必需 |
| `regions` | `list(string)` | `null` | No | 要采集的地域 | 当 `resource_mode = "attributeMode"` 时必需 |
| `resource_tags` | `map(string)` | `null` | No | 资源标签 | 当 `resource_mode = "attributeMode"` 时有效 |

#### Resource Directory 对象结构

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `enabled` | `bool` | `true` | No | 是否启用多账号采集 | - |
| `account_group_type` | `string` | `"all"` | No | 账号组类型 | 必须是：`all` 或 `custom` |
| `members` | `list(string)` | `[]` | No | 成员账号列表 | 当 `account_group_type = "custom"` 时必需 |

#### Logstore 对象结构

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | `null` | No | 日志库名称 | 如果为 null 则自动生成。2-63 个字符 |
| `create` | `bool` | `true` | No | 是否创建日志库 | 当 `create = false` 时需要 `name` |
| `retention_period` | `number` | `30` | No | 数据保留时间（天） | 1-3650 |
| `shard_count` | `number` | `2` | No | 分片数 | - |
| `auto_split` | `bool` | `true` | No | 是否自动分裂分片 | - |
| `max_split_shard_count` | `number` | `64` | No | 自动分裂的最大分片数 | 1-256，当 `auto_split = true` 时必需 |
| `mode` | `string` | `"standard"` | No | 存储模式 | 必须是：`standard`、`query` 或 `lite` |
| `metering_mode` | `string` | `null` | No | 计费模式 | 必须是：`ChargeByFunction` 或 `ChargeByDataIngest` |
| `telemetry_type` | `string` | `null` | No | 存储类型 | 空表示日志库，`Metrics` 表示指标库 |
| `hot_ttl` | `number` | `30` | No | 热存储 TTL（天） | >= 30，必须 <= retention_period |
| `infrequent_access_ttl` | `number` | `null` | No | 低频存储时间（天） | - |
| `append_meta` | `bool` | `true` | No | 是否自动追加日志元数据 | - |

## 输出参数

| Name | Description |
|------|-------------|
| `project_name` | SLS 项目名称 |
| `logstore_names` | 创建的日志库名称（按 policy_name 映射） |
| `collection_policy_names` | 创建的采集策略名称（按 policy_name 映射） |
| `collection_policy_ids` | 创建的采集策略 ID（按 policy_name 映射） |
| `collection_policy_status` | 采集策略状态（按 policy_name 映射） |
| `collection_policies_summary` | 按 product_code 分组的采集策略摘要 |

## 使用示例

### 基础日志审计配置

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit  # cn-shanghai 或 ap-southeast-1
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "central-log-audit"
  create_project = true

  collection_policies = [
    {
      policy_name  = "ecs-audit"
      product_code = "ecs"
      enabled      = true
      data_code    = "audit_log"
      policy_config = {
        resource_mode = "all"
      }
      logstore = {
        create           = true
        retention_period = 180
      }
    }
  ]
}
```

### 多账号采集

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "central-log-audit"
  create_project = true

  collection_policies = [
    {
      policy_name  = "ecs-audit"
      product_code = "ecs"
      enabled      = true
      data_code    = "audit_log"
      policy_config = {
        resource_mode = "all"
      }
      resource_directory = {
        enabled            = true
        account_group_type = "all"  # 从所有账号采集
      }
      logstore = {
        create           = true
        retention_period = 180
      }
    }
  ]
}
```

### 属性模式采集

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "central-log-audit"
  create_project = true

  collection_policies = [
    {
      policy_name  = "waf-access"
      product_code = "waf"
      enabled      = true
      data_code    = "access_log"
      policy_config = {
        resource_mode = "attributeMode"
        regions       = ["cn-hangzhou", "cn-shanghai"]
        resource_tags = {
          Environment = "production"
        }
      }
      logstore = {
        create           = true
        retention_period = 90
      }
    }
  ]
}
```

## 注意事项

- **Provider 地域限制**：`alicloud.log_audit` provider 必须使用 `cn-shanghai` 或 `ap-southeast-1` 地域
- SLS 项目可以在任何支持的地域创建（不受 log_audit provider 地域限制）
- 日志采集可以覆盖所有地域，不受 provider 地域限制
- 策略名称在项目内必须唯一
- 日志库名称在项目内必须唯一
- 关于 product_code 和 data_code 的值，请参考[阿里云文档](https://help.aliyun.com/zh/sls/cloud-product-configuration-considerations)
- 某些 product_code/data_code 组合有特定要求（例如 resource_mode 必须是 `all` 或 `attributeMode`）
- 当 `resource_mode = "attributeMode"` 时，`regions` 是必需的
- 当 `resource_mode = "instanceMode"` 时，`instance_ids` 是必需的
- 如果未指定日志库名称，默认为 `central-{productCode}-{dataCode}-{policyName}`
- 采集策略支持集中式日志传输到 SLS

