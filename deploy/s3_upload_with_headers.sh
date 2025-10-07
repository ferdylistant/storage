#!/bin/bash
set -euo pipefail

SOURCE_DIR="./public/build"
DESTINATION="s3://${AWS_S3_BUCKET_NAME}/mm/${DEPLOYED_VERSION}/build"

upload_file() {
  local file="$1"
  local ext="${file##*.}"
  local mime=""
  local cache_control="public, max-age=31536000, immutable"

  case "$ext" in
    js) mime="application/javascript" ;;
    css) mime="text/css" ;;
    html) mime="text/html" ;;
    svg) mime="image/svg+xml" ;;
    json) mime="application/json" ;;
    woff) mime="font/woff" ;;
    woff2) mime="font/woff2" ;;
    ttf) mime="font/ttf" ;;
    eot) mime="application/vnd.ms-fontobject" ;;
    otf) mime="font/otf" ;;
    webp) mime="image/webp" ;;
    png) mime="image/png" ;;
    jpg|jpeg) mime="image/jpeg" ;;
    gif) mime="image/gif" ;;
    map) mime="application/json" ;;
    *) mime="application/octet-stream" ;;
  esac

  relative_path="${file#$SOURCE_DIR/}"
  s3_path="$DESTINATION/$relative_path"

  echo "Uploading: $file ➜ $s3_path"
  aws s3 cp "$file" "$s3_path" \
    --content-type "$mime" \
    --cache-control "$cache_control"
}

export -f upload_file
export SOURCE_DIR DESTINATION DEPLOYED_VERSION

find "$SOURCE_DIR" -type f | while read -r file; do
  upload_file "$file"
done
