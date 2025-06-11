variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "node_group_name" {
  type        = string
  description = "The name of the node group"
  default     = "default"
}

variable "namespace" {
  type        = string
  description = "The name of the namespace"
  default     = "default"
}

variable "cluster_version" {
  type        = string
  description = "The version of the EKS cluster"
}

variable "desired_capacity" {
  type        = number
  description = "The desired number of nodes in the node group"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "The minimum size of the node group"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "The maximum size of the node group"
  default     = 2
}

