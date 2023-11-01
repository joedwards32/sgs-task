# sgs-task
Simple Gaming Service Task
## Requirements

The following requirements are needed by this module:

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 5.23)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (~> 5.23)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_cloudwatch_log_group.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_ecs_service.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) (resource)
- [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) (resource)
- [aws_efs_access_point.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) (resource)
- [aws_route53_record.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)
- [aws_security_group.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_network_interface.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) (data source)
- [aws_network_interfaces.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interfaces) (data source)
- [aws_route53_zone.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_container_image"></a> [container\_image](#input\_container\_image)

Description: Container image

Type: `string`

### <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone)

Description: AWS Route53 DNS zone to create A record in

Type: `string`

### <a name="input_logging_region"></a> [logging\_region](#input\_logging\_region)

Description: AWS region

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Desired task name

Type: `string`

### <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings)

Description: Array of json port definitions

Type:

```hcl
list(object({
    hostPort = number
    containerPort = number
    protocol = string
  }))
```

### <a name="input_sgs_cluster"></a> [sgs\_cluster](#input\_sgs\_cluster)

Description: Simple Gaming Service ECS cluster

Type:

```hcl
object({
    arn                           = string
    id                            = string
    vpc_id                        = string
    subnet_id                     = string
    efs_id                        = string
    efs_clients_security_group_id = string
    execution_role_arn            = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_cpu"></a> [cpu](#input\_cpu)

Description: Fargate CPU units

Type: `number`

Default: `512`

### <a name="input_disk"></a> [disk](#input\_disk)

Description: Fargate ephemeral storage GiB

Type: `number`

Default: `21`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: Array of environment variables

Type:

```hcl
list(object({
    name = string
    value = string
  }))
```

Default: `[]`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: Fargate Memory units

Type: `number`

Default: `1024`

### <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points)

Description: Array of environment variables

Type:

```hcl
list(object({
    containerPath = string
    sourceVolume = string
  }))
```

Default: `[]`

### <a name="input_running"></a> [running](#input\_running)

Description: Whether task should be running or not

Type: `bool`

Default: `true`

### <a name="input_volumes"></a> [volumes](#input\_volumes)

Description: List of objects representing EFS file systems to create and paths to mount them

Type:

```hcl
list(object({
    name = string
    mount_point = string
  }))
```

Default: `[]`

## Outputs

The following outputs are exported:

### <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name)

Description: n/a

### <a name="output_ecs_service_id"></a> [ecs\_service\_id](#output\_ecs\_service\_id)

Description: n/a

### <a name="output_privateipv4"></a> [privateipv4](#output\_privateipv4)

Description: n/a

### <a name="output_publicipv4"></a> [publicipv4](#output\_publicipv4)

Description: n/a
