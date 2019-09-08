## outputs of rds_mysql_hive_metastore
output "rds_mysql_hive_metastore_db_instance_address" {
  description = "The address of the RDS instance"
  value       = "${module.rds_mysql_hive_metastore.this_db_instance_address}"
}

output "rds_mysql_hive_metastore_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = "${module.rds_mysql_hive_metastore.this_db_instance_arn}"
}

output "rds_mysql_hive_metastore_db_instance_id" {
  description = "The RDS instance ID"
  value       = "${module.rds_mysql_hive_metastore.this_db_instance_id}"
}

output "rds_mysql_hive_metastore_db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = "${module.rds_mysql_hive_metastore.this_db_instance_resource_id}"
}

output "rds_mysql_hive_metastore_db_instance_status" {
  description = "The RDS instance status"
  value       = "${module.rds_mysql_hive_metastore.this_db_instance_status}"
}

output "rds_mysql_hive_metastore_db_instance_name" {
  description = "The database name"
  value       = "${module.rds_mysql_hive_metastore.this_db_instance_name}"
}


## outputs of s3_bucket_emr_cluster
output "s3_bucket_emr_cluster_id" {
  description = "The name of the bucket."
  value       = "${module.s3_bucket_emr_cluster.this_s3_bucket_id}"
}

output "s3_bucket_emr_cluster_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = "${module.s3_bucket_emr_cluster.this_s3_bucket_arn}"
}

output "s3_bucket_emr_cluster_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = "${module.s3_bucket_emr_cluster.this_s3_bucket_domain_name}"
}

output "s3_bucket_emr_cluster_region" {
  description = "The AWS region this bucket resides in."
  value       = "${module.s3_bucket_emr_cluster.this_s3_bucket_region}"
}

output "s3_bucket_emr_cluster_tags" {
  description = "List of tags"
  value       = "${module.s3_bucket_emr_cluster.this_s3_bucket_tags}"
}


## outputs of emr_cluster
output "emr_cluster_master_id" {
  description = "Instance ID of master node"
  value       = "${module.emr_cluster.this_master_id}"
}

output "emr_cluster_master_private_ip" {
  description = "Private IP of master node"
  value       = "${module.emr_cluster.this_master_private_ip}"
}

output "emr_cluster_master_public_dns" {
  description = "Public DNS of master node"
  value       = "${module.emr_cluster.this_master_public_dns}"
}

output "emr_cluster_master_security_groups" {
  description = "List of security groups"
  value       = "${module.emr_cluster.this_master_security_groups}"
}

output "emr_cluster_tags" {
  description = "List of tags"
  value       = "${module.emr_cluster.this_aws_emr_cluster_tags}"
}
