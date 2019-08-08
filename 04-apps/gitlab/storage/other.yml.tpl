# Example configuration of `connection` secret for Rails
# Example for Google Cloud Storage
#   See https://gitlab.com/charts/gitlab/blob/master/doc/charts/globals.md#connection
#   See https://gitlab.com/charts/gitlab/blob/master/doc/advanced/external-object-storage
provider: Google
google_project: ${google_project_id}
google_client_email: ${google_client_email}
# Ensure indentation is correct for `google_json_key_string`
# - YAML is a superset of JSON, so you can paste & indent
#   `example-project-382839-gcs-bucket.json` 2-4 spaces directly.
google_json_key_string: |
  ${google_json_key_string}
