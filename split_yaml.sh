#!/bin/bash
# split_yaml.sh
# Usage: ./split_yaml.sh <URL>

URL=$1
curl -s $URL | awk '/^---$/ {flush=1; next} {if(flush) {print buf; buf = ""}; flush=0; buf = buf "\n" $0} END {print buf}' \
  | jq -R -s -c 'split("\n\n") | map(select(length > 0)) | to_entries | reduce .[] as $item ({}; .[$item.key|tostring] = $item.value)'
