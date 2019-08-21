variable "namespace" {
  default = "default"
}

variable "image" {
  default = "postgres:11.5"
}

variable "master_node_selector" {
  type = map(string)
  default = {
    node_type = "pg-master"
  }
}

variable "slave_node_selector" {
  type = map(string)
  default = {
    node_type = "pg-slave"
  }
}

variable "slave_count" {}
variable "slave_disk_size" {}

variable "slave_disk_type" {
  default = "ssd"
}


variable "checkpoint_completion_target" {}
variable "default_statistics_target" {}
variable "effective_cache_size" {}
variable "effective_io_concurrency" {}
variable "maintenance_work_mem" {}
variable "max_connections" {}
variable "max_parallel_workers" {}
variable "max_parallel_workers_per_gather" {}
variable "max_wal_size" {}
variable "max_worker_processes" {}
variable "min_wal_size" {}
variable "random_page_cost" {}
variable "shared_buffers" {}
variable "wal_buffers" {}
variable "work_mem" {}

