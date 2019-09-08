## Provider
provider "aws" {
  version = "~> 2.20.0"
  profile = "default"
  region  = "${var.region}"
}


## Shared Data
## data: default_vpc
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}

## Shared KMS Customer Managed Key
## aws_kms: cmk_emr_cluster
resource "aws_kms_key" "cmk_emr_cluster" {
  description             = "This KMS Customer Managed Key is used to encrypt emr-cluster related resources"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "cmk_emr_cluster" {
  name          = "alias/cmk-emr-cluster"
  target_key_id = "${aws_kms_key.cmk_emr_cluster.key_id}"
}


## Module
## emr_cluster_hive_metastore: rds_mysql_hive_metastore
module "rds_mysql_hive_metastore" {
  source = "./modules/terraform-aws-rds"

  identifier = "hive-metastore"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine            = "mysql"
  engine_version    = "5.7.26"
  instance_class    = "db.t3.micro"
  allocated_storage = 25
  multi_az          = true

  storage_encrypted = true
  kms_key_id        = "${aws_kms_key.cmk_emr_cluster.arn}"

  name     = "hive_metastore"
  username = "hive_dbuser"
  password = "hive_dbpass"
  port     = "3306"

  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Disable backups to create DB faster
  backup_retention_period = 0

  enabled_cloudwatch_logs_exports = ["audit", "general"]

  # DB subnet group
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "hive-metastore"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]

  tags = {
    Owner       = "${var.cluster_name}"
    Environment = "${var.environment}"
  }
}


## Module
## emr_cluster_s3_bucket: s3_bucket_emr_cluster
module "s3_bucket_emr_cluster" {
  source = "./modules/terraform-aws-s3-bucket"

  bucket = "your-prefix-s3-bucket-emr-cluster"
  acl    = "private"

  force_destroy = true

  tags = {
    Owner = "${var.cluster_name}"
  }

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = "${aws_kms_key.cmk_emr_cluster.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_emr_cluster" {
  bucket = "${module.s3_bucket_emr_cluster.this_s3_bucket_id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


## Module
## emr_cluster: emr_cluster_default_security_groups
resource "aws_security_group" "emr_cluster_master" {
  name                   = "emr_cluster_sg_master"
  description            = "Managed by Terraform"
  vpc_id                 = "${data.aws_vpc.default.id}"
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "emr_cluster_sg_master"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "emr_cluster_slave" {
  name                   = "emr_cluster_sg_slave"
  description            = "Managed by Terraform"
  vpc_id                 = "${data.aws_vpc.default.id}"
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "emr_cluster_sg_slave"
    Environment = "${var.environment}"
  }
}

## emr_cluster: emr_cluster
module "emr_cluster" {
  source = "./modules/terraform-aws-emr-cluster"

  cluster_name  = "${var.cluster_name}"
  release_label = "emr-5.26.0"
  applications  = ["Hadoop", "Hive", "Spark", "Zeppelin"]
  subnet_id     = "${data.aws_subnet_ids.default.ids[0]}"
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

  ## Enable the bootstrap_action block if you need
  # bootstrap_action_path = "s3://elasticmapreduce/bootstrap-actions/run-if"
  # bootstrap_action_name = "runif"
  # bootstrap_action_args = ["instance.isMaster=true", "echo running on master node"]

  tags = {
    Name        = "${var.cluster_name}"
    Environment = "${var.environment}"
  }
}
