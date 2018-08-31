#!/bin/bash -xe

BUCKET="$(/usr/share/google/get_metadata_value attributes/backup_bucket)"
LOCAL_PATH="/var/lib/zeppelin/notebook"
GCS_PATH="gs://${BUCKET}/backup/zeppelin/notebook"

while inotifywait -r -e modify,create,delete ${LOCAL_PATH}
do
    gsutil -m rsync -r ${LOCAL_PATH} ${GCS_PATH}
done
