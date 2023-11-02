# Process docker image tag, apply ':latest' tag if no tag is defined
locals {
  image_tag = split(":", "${var.container_image}")
  container_image = length(local.image_tag) > 1 ? join("", [local.image_tag[0], ":", local.image_tag[1]]) : join("", [local.image_tag[0], ":latest"])
}

# Create Cloudwatch log group

resource "aws_cloudwatch_log_group" "task" {
  name = "/simple-gaming-service/${var.name}"

  tags = {
    Application = "${var.name}"
  }
}

# Define ECS task

resource "aws_ecs_task_definition" "task" {
  network_mode             = "awsvpc"
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.sgs_cluster.execution_role_arn
  ephemeral_storage {
    size_in_gib =  "${var.disk}"
  }
  container_definitions = jsonencode([{
   name         = "${var.name}-container"
   image        = "${local.container_image}"
   essential    = true
   portMappings = "${var.port_mappings}"
   environment  = "${var.environment_variables}"
   mountPoints  = "${var.mount_points}"
   logConfiguration = {
    logDriver  = "awslogs"
    options    = {
     "awslogs-group": aws_cloudwatch_log_group.task.name,
     "awslogs-region": "${var.logging_region}",
     "awslogs-stream-prefix": "streaming"   
    } 
   }
  }])
  dynamic "volume" {
    for_each = { for fs in var.volumes: fs.name => fs }
    content {
      name = volume.value.name
      efs_volume_configuration {
        file_system_id   = var.sgs_cluster.efs_id
        transit_encryption = "ENABLED"
        authorization_config {
          access_point_id = aws_efs_access_point.task[volume.key].id
        }
      }
    }
  }
}

# Define Task Security Group

resource "aws_security_group" "task" {
  name        = "sgs-task-${var.name}"
  description = "Control traffic for SGS task ${var.name}"
  vpc_id      = var.sgs_cluster.vpc_id 
}

resource "aws_security_group_rule" "ingress" {
  for_each = {for mapping in var.port_mappings: mapping.hostPort => mapping}

  security_group_id = aws_security_group.task.id
  type              = "ingress"
  from_port         = each.value.hostPort
  to_port           = each.value.hostPort
  protocol          = each.value.protocol
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.task.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# Define EFS Access Point
resource "aws_efs_access_point" "task" {
  for_each = { for fs in var.volumes: fs.name => fs }
  file_system_id = var.sgs_cluster.efs_id
  root_directory {
    path = each.value.mount_point
    creation_info {
      owner_uid = 65534
      owner_gid = 65534
      permissions = "0777"
    }
  }
}

# Define ECS Service

resource "aws_ecs_service" "task" {
  depends_on = [aws_efs_access_point.task]
  name            = var.name
  launch_type     = "FARGATE"
  cluster         = var.sgs_cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.running  == true ? 1 : 0
  wait_for_steady_state = true
  network_configuration {
    subnets = [var.sgs_cluster.subnet_id]
    assign_public_ip = true
    security_groups = compact([aws_security_group.task.id, var.sgs_cluster.efs_clients_security_group_id])
  }
}

# Define DNS Record

data "aws_network_interfaces" "task" {
  # depends_on required as IP address information will not be
  # available until aws_ecs_service.task has been created and the
  # resulting container added to the security group.
  depends_on = [aws_ecs_service.task]
  filter {
    name   = "group-id"
    values = [aws_security_group.task.id]
  }
}

data "aws_network_interface" "task" {
  count = var.running == true ? 1 : 0
  id    = join(",", data.aws_network_interfaces.task.ids)
}

data "aws_route53_zone" "task" {
  name = var.dns_zone
}

resource "aws_route53_record" "task" {
  count   = var.running == true ? 1 : 0
  zone_id = data.aws_route53_zone.task.zone_id
  name    = "${var.name}.${data.aws_route53_zone.task.name}"
  type    = "A"
  ttl     = "60"
  records = tolist( data.aws_network_interface.task[*].association[0].public_ip ) 
}
