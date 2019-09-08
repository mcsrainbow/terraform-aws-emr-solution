output "this_master_id" {
  description = "Instance ID of master node"
  value = "${data.aws_instance.this_master.id}"
}

output "this_master_private_ip" {
  description = "Private IP of master node"
  value = "${data.aws_instance.this_master.private_ip}"
}

output "this_master_public_dns" {
  description = "Public DNS name of master node"
  value = "${data.aws_instance.this_master.public_dns}"
}

output "this_master_security_groups" {
  description = "List of security groups"
  value = "${data.aws_instance.this_master.security_groups}"
}

output "this_aws_emr_cluster_tags" {
  description = "List of tags"
  value = "${aws_emr_cluster.this.tags}"
}
