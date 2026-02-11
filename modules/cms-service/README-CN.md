<div align="right">

**中文** | [English](README.md)

</div>

# CMS 服务模块

该模块用于启用阿里云云监控（CloudMonitor，CMS）基础版，并可选启用企业版。

## 功能特性

- 启用云监控基础版（始终启用）
- 可选启用云监控企业版
- 创建云监控所需的服务关联角色

## 输入参数

| 参数名              | 说明                                                         | 类型  | 默认值  | 必填 |
|---------------------|--------------------------------------------------------------|-------|---------|------|
| `enable_enterprise` | 是否启用云监控企业版。如果为 `false`，仅启用基础版。         | `bool` | `false` | 否   |

## 输出参数

| 名称                             | 说明                                           |
|----------------------------------|------------------------------------------------|
| `basic_cloud_monitor_service_id` | 云监控基础版服务 ID                            |
| `enterprise_cloud_monitor_service_id` | 云监控企业版服务 ID（未启用时为 null） |

## 使用示例

```hcl
module "cms_service" {
  source = "./modules/cms-service"

  enable_enterprise = true
}
```


