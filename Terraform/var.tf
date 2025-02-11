
variable "instance_type" {
  description = "instanct type in aws"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "region in aws"
  type        = string
  default     = "us-east-1"

}

variable "ami" {
  description = "ami ubuntu "
  type        = string
  default     = "ami-0e1bed4f06a3b463d"

}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}


variable "ssh_key_name" {
  description = "Name of the AWS EC2 key pair"
  type        = string
  default     = "new"  # Default key name in AWS
}