#!/usr/bin/bash -xe

OWNER=`hostname | cut -d- -f3`
LOCAL_PATH="/var/lib/zeppelin/notebook"
GCS_PATH="gs://de-training-output-${OWNER}/backup/zeppelin/notebook"

while inotifywait -r -e modify,create,delete ${LOCAL_PATH}
do
    gsutil -m rsync ${LOCAL_PATH} ${GCS_PATH}
done
