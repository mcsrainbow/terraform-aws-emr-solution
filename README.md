# terraform-aws-emr-solution

A better Terraform solution to create an AWS EMR cluster, including:
- KMS(Server Side Encryption for S3 and RDS)
- S3(Cluster Logs and Zeppelin Notebook)
- RDS(External Hive Metastore Database)
- IAM(Roles with AWS Managed Policies)
- EMR(Fully Functional Cluster with Autoscaling Enabled)

## Structure

```
.
├── README.md
├── main.tf
├── modules
│   ├── terraform-aws-emr-cluster
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── templates
│   │   │   ├── autoscaling_policy.json.tpl
│   │   │   └── configurations.json.tpl
│   │   └── variables.tf
│   ├── terraform-aws-rds
│   │   ├── README.md
│   │   ├── examples
│   │   ├── main.tf
│   │   ├── modules
│   │   │   ├── db_instance
│   │   │   ├── db_option_group
│   │   │   ├── db_parameter_group
│   │   │   └── db_subnet_group
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── terraform-aws-s3-bucket
│       ├── README.md
│       ├── examples
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
└── variables.tf
```

## Usage

```hcl
...

## emr_cluster: emr_cluster
module "emr_cluster" {
  source = "./modules/terraform-aws-emr-cluster"

  cluster_name  = "${var.cluster_name}"
  release_label = "emr-5.26.0"
  applications  = ["Hadoop", "Hive", "Spark", "Zeppelin"]
  subnet_id     = tolist(data.aws_subnet_ids.default.ids)[0]
  key_name      = "aws-use-keypair"

  master_instance_type    = "m5.xlarge"
  core_instance_type      = "c5.xlarge"
  core_instance_count_min = 1   # To manually resize the cluster, update this value
  core_instance_count_max = 4   # MaxCapacity in Autoscaling Policy
  bid_price               = 1.5 # Declare Core Instance Group as a Spot Instance
  core_volume_size        = 32  # Default value is 32 GiB
  ebs_root_volume_size    = 10  # Default value is 10 GiB

  # Keep the Cluster logs and Zeppelin Notebooks on S3 bucket
  s3_bucket = "${module.s3_bucket_emr_cluster.this_s3_bucket_id}"

  # Attache the additional default VPC security group on Master node
  master_security_group = "${aws_security_group.emr_cluster_master.id}"
  addnl_security_groups = "${data.aws_security_group.default.id}"
  slave_security_group  = "${aws_security_group.emr_cluster_slave.id}"

  # External Hive Metastore Database
  # To use an existing Hive Metastore Database, remember to update the DB_LOCATION_URI as new Master node hostname in table DBS
  #
  # MySQL [hive_metastore]> select * from DBS;
  # +-------+-----------------------+----------------------------------------------------------------------------+---------+------------+------------+
  # | DB_ID | DESC                  | DB_LOCATION_URI                                                            | NAME    | OWNER_NAME | OWNER_TYPE |
  # +-------+-----------------------+----------------------------------------------------------------------------+---------+------------+------------+
  # |     1 | Default Hive database | hdfs://ip-172-31-1-234.us-east-1.compute.internal:8020/user/hive/warehouse | default | public     | ROLE       |
  # +-------+-----------------------+----------------------------------------------------------------------------+---------+------------+------------+
  hive_metastore_address = "${module.rds_mysql_hive_metastore.this_db_instance_address}"
  hive_metastore_name    = "${module.rds_mysql_hive_metastore.this_db_instance_name}"
  hive_metastore_user    = "${module.rds_mysql_hive_metastore.this_db_instance_username}"
  hive_metastore_pass    = "hive_dbpass"

  tags = {
    Name        = "${var.cluster_name}"
    Environment = "${var.environment}"
  }
}
```

## Outputs

- `rds_mysql_hive_metastore_db_instance_address` - "The address of the RDS instance"
- `rds_mysql_hive_metastore_db_instance_arn` - "The ARN of the RDS instance"
- `rds_mysql_hive_metastore_db_instance_id` - "The RDS instance ID"
- `rds_mysql_hive_metastore_db_instance_resource_id` - "The RDS Resource ID of this instance"
- `rds_mysql_hive_metastore_db_instance_status` - "The RDS instance status"
- `rds_mysql_hive_metastore_db_instance_name` - "The database name"
- `s3_bucket_emr_cluster_id` - "The name of the bucket"
- `s3_bucket_emr_cluster_arn` - "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
- `s3_bucket_emr_cluster_domain_name` - "The bucket domain name as bucketname.s3.amazonaws.com"
- `s3_bucket_emr_cluster_region` - "The AWS region this bucket resides in."
- `s3_bucket_emr_cluster_tags` - "List of tags"
- `emr_cluster_master_id` - "Instance ID of master node"
- `emr_cluster_master_private_ip` - "Private IP of master node"
- `emr_cluster_master_public_dns`- "Public DNS of master node"
- `emr_cluster_master_security_groups` - "List of security groups"
- `emr_cluster_tags` - "List of tags"
