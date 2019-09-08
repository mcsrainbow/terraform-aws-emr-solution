[
  {
    "Classification": "hadoop-env",
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
        }
      }
    ],
    "Properties": {}
  },
  {
    "Classification": "spark-env",
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
        }
      }
    ],
    "Properties": {}
  },
  {
    "Classification": "zeppelin-env",
    "Properties": {},
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "ZEPPELIN_NOTEBOOK_STORAGE": "org.apache.zeppelin.notebook.repo.S3NotebookRepo",
          "ZEPPELIN_NOTEBOOK_S3_BUCKET": "${zeppelin_notebook_s3_bucket}",
          "ZEPPELIN_NOTEBOOK_S3_USER": "${zeppelin_notebook_s3_user}"
        },
        "Configurations": []
      }
    ]
  },
  {
    "Classification": "hive-site",
    "Properties": {
      "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_address}:3306/${hive_metastore_name}?createDatabaseIfNotExist=true",
      "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver",
      "javax.jdo.option.ConnectionUserName": "${hive_metastore_user}",
      "javax.jdo.option.ConnectionPassword": "${hive_metastore_pass}",     
      "hive.stats.autogather": "${hive_stats_autogather}"
    }
  }
]