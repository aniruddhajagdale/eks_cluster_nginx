variable "env" {
  type        = string
  description = "Environment name"
}
variable "cluster_name" {
  type        = string
  description = "Application name"
}
variable "k8_version" {
  type        = string
  description = "Kubernetes version"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet ids"
}
variable "instance_types" {
  type        = list(string)
  description = "Instance types"
}
variable "desired_size" {
  type        = number
  description = "Desired size"
}
variable "max_nodes" {
  type        = number
  description = "Max size"
}
variable "min_nodes" {
  type        = number
  description = "Min size"
}