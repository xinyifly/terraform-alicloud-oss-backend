provider "alicloud" {
  version = ">= 1.56.0"
  region  = var.region
}

locals {
  oss_bucket   = "tf-state-${var.scope}"
  ots_instance = "tf-lock-${var.scope}"
}

resource "alicloud_oss_bucket" "this" {
  count = var.create_oss_bucket ? 1 : 0

  bucket = local.oss_bucket
}

resource "alicloud_ots_instance" "this" {
  count = var.create_ots_instance ? 1 : 0

  name = local.ots_instance
}

resource "alicloud_ots_table" "this" {
  instance_name = local.ots_instance

  table_name   = "tf_lock_${var.name}"
  max_version  = 1
  time_to_live = -1

  primary_key {
    name = "init"
    type = "String"
  }
}

resource "local_file" "this" {
  filename        = "${path.root}/backend.tf"
  file_permission = "0644"

  content = <<-EOT
    terraform {
      backend "oss" {
        bucket              = "${local.oss_bucket}"
        region              = "${var.region}"
        prefix              = "${var.name}"
        tablestore_endpoint = "https://${local.ots_instance}.${var.region}.ots.aliyuncs.com"
        tablestore_table    = "${alicloud_ots_table.this.table_name}"
      }
    }
  EOT
}
