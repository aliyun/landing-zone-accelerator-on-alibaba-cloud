<div align="right">

**中文** | [English](README.md)

</div>

# CEN 组件

该组件用于创建和管理阿里云 CEN（云企业网）实例和转发路由器，实现 VPC 间互联。

## 功能特性

- 创建 CEN 实例
- 创建转发路由器
- 自动开通转发路由器服务
- 获取转发路由器系统路由表 ID
- 支持为 CEN 实例和转发路由器添加标签

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_transit_router_service.enable](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_service) | data source | 转发路由器服务开通 |
| [alicloud_cen_transit_router_route_tables.route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_route_tables) | data source | 转发路由器路由表查询 |
| [alicloud_cen_instance.cen](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance) | resource | CEN 实例 |
| [alicloud_cen_transit_router.cen_tr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router) | resource | 转发路由器 |

## 使用方法

```hcl
module "cen" {
  source = "./components/network/cen"

  cen_instance_name        = "enterprise-cen"
  cen_instance_description = "企业 CEN 实例"
  transit_router_name      = "enterprise-tr"
  transit_router_description = "企业转发路由器"
  
  cen_instance_tags = {
    Environment = "production"
  }
  
  transit_router_tags = {
    Environment = "production"
  }
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_name` | CEN 实例名称 | `string` | `null` | No | 非空时 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `cen_instance_description` | CEN 实例描述 | `string` | `null` | No | 非空时 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `cen_instance_tags` | 分配给 CEN 实例的标签 | `map(string)` | `null` | No | - |
| `transit_router_name` | 转发路由器名称 | `string` | `null` | No | 非空时 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `transit_router_description` | 转发路由器描述 | `string` | `null` | No | 非空时 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `transit_router_tags` | 分配给转发路由器的标签 | `map(string)` | `null` | No | - |

## 输出参数

| Name | Description |
|------|-------------|
| `cen_instance_id` | 创建的 CEN 实例 ID |
| `transit_router_id` | 创建的转发路由器 ID |
| `system_transit_router_route_table_id` | 系统转发路由器路由表 ID |

## 使用示例

### 基础 CEN 配置

```hcl
module "cen" {
  source = "./components/network/cen"

  cen_instance_name = "my-cen"
  transit_router_name = "my-tr"
}
```

### CEN 配置标签

```hcl
module "cen" {
  source = "./components/network/cen"

  cen_instance_name        = "enterprise-cen"
  cen_instance_description = "企业 CEN"
  transit_router_name      = "enterprise-tr"
  
  cen_instance_tags = {
    Environment = "production"
    Project     = "landing-zone"
  }
  
  transit_router_tags = {
    Environment = "production"
  }
}
```

## 注意事项

- 创建资源前会自动开通转发路由器服务
- CEN 实例和转发路由器按顺序创建（转发路由器依赖于 CEN 实例）
- 自动获取系统路由表 ID 供 VPC 连接使用
- 名称和描述不能以 `http://` 或 `https://` 开头
- 可以为 CEN 实例和转发路由器添加标签用于资源管理

