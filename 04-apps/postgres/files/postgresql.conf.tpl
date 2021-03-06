listen_addresses = '*'
max_connections = ${max_connections}
shared_buffers = ${shared_buffers}
effective_cache_size = ${effective_cache_size}
maintenance_work_mem = ${maintenance_work_mem}
checkpoint_completion_target = 0.7
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = ${work_mem}
min_wal_size = 1GB
max_wal_size = 2GB
max_worker_processes = 2
max_parallel_workers_per_gather = 1
max_parallel_workers = 2
