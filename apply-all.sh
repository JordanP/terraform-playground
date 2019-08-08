#!/usr/bin/env bash
set -ueo pipefail

while IFS= read -r -d '' d
do
  cd "$d" || exit
  terraform apply -auto-approve && sleep 30
  cd .. || exit
done < <(find . -maxdepth 1 -mindepth 1 -type d -iname "0*" -print0)
