# Azure Service Bus feature
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/service-bus/azurerm/)

This Terraform module creates an [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus/).

## Requirements

* [AzureRM Terraform provider](https://www.terraform.io/docs/providers/azurerm/) >= 1.32

## Version compatibility

| Module version    | Terraform version | AzureRM version |
|-------------------|-------------------|-----------------|
| >= 3.x.x          | 0.12.x            | >= 2.0          |
| >= 2.x.x, < 3.x.x | 0.12.x            | <  2.0          |
| <  2.x.x          | 0.11.x            | <  2.0          |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

You can use this module by including it this way:

```hcl
module "azure-region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure-region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "servicebus" {
  source  = "claranet/service-bus/azurerm"
  version = "x.x.x"

  location       = module.azure-region.location
  location_short = module.azure-region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  servicebus_namespaces_queues = {
    # You can just create a servicebus_namespace
    servicebus0 = {}

    # Or create a servicebus_namespace with some queues with default values
    servicebus1 = {
      queues = {
        queue1 = {}
        queue2 = {}
      }
    }

    # Or customize everything
    servicebus2 = {
      custom_name = format("%s-%s-%s-custom", var.stack, var.client_name, module.azure-region.location_short)
      sku         = "Premium"
      capacity    = 2

      queues = {
        queue100 = {
          reader = true
          sender = true
          manage = true
        }
        queue200 = {
          dead_lettering_on_message_expiration = true
          default_message_ttl                  = "PT10M"
          reader                               = true
        }
        queue300 = {
          duplicate_detection_history_time_window = "PT30M"
          sender                                  = true
        }
        queue400 = {  
          requires_duplicate_detection = true
          manage                       = true
        }
      }
    }
  }
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| client\_name | Client name/account used in naming | `string` | n/a | yes | 
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| location | Azure location for Servicebus. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| resource\_group\_name | Name of the resource group | `string` | n/a | yes |
| servicebus\_namespaces\_queues | Map to handle Servicebus creation. It supports the creation of the queues, authorization\_rule associated with each namespace you create | `any` | n/a | yes |
| stack | Project stack name | `string` | n/a | yes |

## Outputs 

| Name | Description |
|------|-------------|
| manages | Map of the manages access policies |
| namespaces | Map of the namespaces |
| queues | Map of the queues |
| readers | Map of the readers access policies |
| senders | Map of the senders access policies |

## Related documentation

Terraform resource documentation on Servicebus namespace: [terraform.io/docs/providers/azurerm/r/servicebus_namespace.html](https://www.terraform.io/docs/providers/azurerm/r/servicebus_namespace.html)
Terraform resource documentation on Servicebus queue: [terraform.io/docs/providers/azurerm/r/servicebus_queue.html](https://www.terraform.io/docs/providers/azurerm/r/servicebus_queue.html)

Microsoft Azure documentation: [docs.microsoft.com/en-us/azure/service-bus/](https://docs.microsoft.com/en-us/azure/service-bus/)
