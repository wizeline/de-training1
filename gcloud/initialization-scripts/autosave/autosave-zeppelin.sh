#!/bin/bash -xe

BUCKET=`curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/backup_bucket" -H "Metadata-Flavor: Google"`
LOCAL_PATH="/var/lib/zeppelin/notebook"
GCS_PATH="gs://${BUCKET}/backup/zeppelin/notebook"

while inotifywait -r -e modify,create,delete ${LOCAL_PATH}
do
    gsutil -m rsync -r ${LOCAL_PATH} ${GCS_PATH}
done
