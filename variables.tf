variable "name" {
  description = "Desired task name"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "sgs_cluster" {
  description = "Simple Gaming Service ECS cluster"
  type        = object({
    arn                           = string
    id                            = string
    vpc_id                        = string
    subnet_id                     = string
    efs_id                        = string
    efs_clients_security_group_id = string
    execution_role_arn            = string
  })
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate Memory units"
  type        = number
  default     = 1024
}

variable "disk" {
  description = "Fargate ephemeral storage GiB"
  type        = number
  default     = 21
}

variable "running" {
  description = "Whether task should be running or not"
  type        = bool
  default     = true
}

variable "logging_region" {
  description = "AWS region"
  type        = string
}

variable "dns_zone" {
  description = "AWS Route53 DNS zone to create A record in"
  type        = string
}

variable "port_mappings" {
  description = "Array of json port definitions"
  type        = list(object({
    hostPort = number
    containerPort = number
    protocol = string
  }))
}

variable "environment_variables" {
  description = "Array of environment variables"
  type        = list(object({
    name = string
    value = string
  }))
  default = []
}

variable "mount_points" {
  description = "Array of environment variables"
  type        = list(object({
    containerPath = string
    sourceVolume = string
  }))
  default = []
}

variable "volumes" {
  description = "List of objects representing EFS file systems to create and paths to mount them"
  type        = list(object({
    name = string
    mount_point = string
  }))
  default = []
}
