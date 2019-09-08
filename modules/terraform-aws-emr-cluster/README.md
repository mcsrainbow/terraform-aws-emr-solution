# terraform-aws-emr-cluster

A Terraform module to create an AWS EMR cluster

## Usage

```hcl
module "module_name" {
  source = "./path/to/module"

  cluster_name  = "${var.cluster_name}"
  release_label = "${var.release_label}"
  applications  = ${var.applications}
  subnet_id     = "${var.subnet_id}"
  key_name      = "${var.key_name}"

  master_instance_type    = "${var.master_instance_type}"
  core_instance_type      = "${var.core_instance_type}"
  core_instance_count_min = "${var.core_instance_count_min}"  # To manually resize the cluster, update this value
  core_instance_count_max = "${core_instance_count_min}"      # MaxCapacity in Autoscaling Policy
  bid_price               = ${var.bid_price}                  # Declare Core Instance Group as a Spot Instance
  core_volume_size        = ${var.core_volume_size}           # Default value is 32 GiB
  ebs_root_volume_size    = ${var.ebs_root_volume_size}       # Default value is 10 GiB

  # Keep the Cluster logs and Zeppelin Notebooks on S3 bucket
  s3_bucket = "${var.s3_bucket}"

  # Attache the additional default VPC security group on Master node
  master_security_group = "${var.master_security_group}"
  addnl_security_groups = "${var.addnl_security_groups}"
  slave_security_group  = "${var.slave_security_group}"

  # External Hive Metastore Database
  hive_metastore_address = "${var.hive_metastore_address}"
  hive_metastore_name    = "${var.hive_metastore_name}"
  hive_metastore_user    = "${var.hive_metastore_user}"
  hive_metastore_pass    = "${var.hive_metastore_pass}"

  tags = {
    Name        = "${var.cluster_name}"
    Environment = "${var.environment}"
  }
}
```

## Outputs

- `this_master_id` - "Instance ID of master node"
- `this_master_private_ip` - "Private IP of master node"
- `this_master_public_dns` - "Public DNS name of master node"
- `this_master_security_groups` - "List of security groups"
- `this_aws_emr_cluster_tags` - "List of tags"