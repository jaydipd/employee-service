variable "ecr_registry" {
  default = "145523123074.dkr.ecr.ap-south-1.amazonaws.com"
}
variable "repo_name" {
  default = "employee-service"
}
variable "image_tag" {
  default = "77"
}
variable "vpc_id" {
  description = "The VPC ID where ECS instances will run"
  type        = string
  default = "my-employee-service-vpc"
}
