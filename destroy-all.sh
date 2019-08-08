#!/usr/bin/env bash
set -ueo pipefail

(cd 04-apps && terraform destroy -auto-approve)
(cd 02-storage && terraform destroy -auto-approve)
(sleep 60 && cd 00-infra && terraform destroy -auto-approve)