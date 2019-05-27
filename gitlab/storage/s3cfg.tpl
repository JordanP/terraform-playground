# https://gitlab.com/charts/gitlab/issues/721
[default]
host_base = storage.googleapis.com
host_bucket = storage.googleapis.com
use_https = True
signature_v2 = True

# Access and secret key can be generated in the interoperability
# https://console.cloud.google.com/storage/settings
# See Docs: https://cloud.google.com/storage/docs/interoperability
access_key = ${access_key}
secret_key = ${secret_key}

# Multipart needs to be disabled for GCS !
enable_multipart = False
