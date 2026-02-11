<div align="right">

**中文** | [English](README.md)

</div>

# Config Configuration Recorder 模块

该模块用于开通阿里云配置审计（Config）服务。

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_config_configuration_recorder.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_configuration_recorder) | resource | 配置审计配置记录器 |

## 使用方法

```hcl
module "config_recorder" {
  source = "./modules/config-configuration-recorder"
}
```

## 输入参数

该模块不需要任何输入变量。它使用默认设置创建配置记录器。

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `recorder_id` | 配置记录器的 ID |
| `status` | 配置记录器的状态 |

## 使用示例

### 基础用法

```hcl
module "config_recorder" {
  source = "./modules/config-configuration-recorder"
}
```


