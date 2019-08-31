resource "random_id" "redis_password" {
  byte_length = 16
}

resource "kubernetes_secret" "redis_password" {
  metadata {
    name = "redis-password"
  }
  data = {
    password = random_id.redis_password.hex
  }
}

resource "random_id" "redis_cm_name" {
  byte_length = 4
  keepers = {
    "redis.conf"   = <<EOF
# stay in foreground
daemonize no
# listen on all interfaces
bind 0.0.0.0
port 6379
timeout 60
tcp-keepalive 300
# Log level
loglevel notice
# Log to stdout
logfile ""
# database count (picked from Omnibus' redis.conf)
databases 16
# Database filename
dbfilename my-gitlab-redis.rdb
# Working Directory (where DB is written)
dir /data/redis
# Configure persistence snapshotting
save 60 1000
save 300 10
save 900 1
EOF
    "configure.sh" = <<EOF
    set -ue
    cat /configmap/redis.conf > /etc/redis/redis.conf
    echo "requirepass $REDIS_PASSWORD" >> /etc/redis/redis.conf
    chmod 640 /etc/redis/redis.conf
EOF
    # So that the configMap name is regenerated if the password changes
    passwd = sha1(random_id.redis_password.hex)
  }
}

resource "kubernetes_config_map" "redis_config" {
  metadata {
    name = "redis-${random_id.redis_cm_name.hex}"
  }
  data = random_id.redis_cm_name.keepers
}
