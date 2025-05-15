variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}
variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}
variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDR block for the private subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR block for the public subnet"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "availability_zones" {
  type        = list(string)
  description = "Availability zones"
  default     = ["us-west-1a", "us-west-1c"]
}
variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "demo-eks"
}
variable "cluster_version" {
  type        = string
  description = "Version of the EKS cluster"
  default     = "1.29"
}
variable "max_size" {
  type        = number
  description = "Maximum number of nodes in the EKS cluster"
  default     = 2
}
variable "min_size" {
  type        = number
  description = "Minimum number of nodes in the EKS cluster"
  default     = 2
}
variable "desired_size" {
  type        = number
  description = "Desired number of nodes in the EKS cluster"
  default     = 2
}
variable "instance_types" {
  type        = list(string)
  description = "Instance types for the EKS nodes"
}