# outputs.tf
output "vpc_name" {
  description = "Name tag of the VPC"
  value       = aws_vpc.monitor_vpc.tags["Name"]
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.monitor_vpc.cidr_block
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.monitor_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "control_instance_name" {
  description = "Name tag of the control instance"
  value       = aws_instance.control-1.tags["Name"]
}

output "target_instance_name" {
  description = "Name tag of the target instance"
  value       = aws_instance.target-1.tags["Name"]
}

output "control_instance_public_ip" {
  description = "Public IP address of the control instance"
  value       = aws_instance.control-1.public_ip
}

output "target_instance_public_ip" {
  description = "Public IP address of the target instance"
  value       = aws_instance.target-1.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.allow_all.id
}

output "instance_ami" {
  description = "AMI ID used for instances"
  value       = var.ami
}

output "ssh_key_name" {
  description = "SSH key name used for instances"
  value       = var.ssh_key_name
}