variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "env" {
  type        = string
  description = "Environment"
}
variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR block for public subnets"
}
variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDR block for private subnets"
}
variable "availability_zones" {
  type        = list(string)
  description = "Availability zones"
}