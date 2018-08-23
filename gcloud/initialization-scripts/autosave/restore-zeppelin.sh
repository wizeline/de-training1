#!/usr/bin/bash -xe

OWNER=`hostname | cut -d- -f3`
LOCAL_PATH="/var/lib/zeppelin/notebook"
GCS_PATH="gs://de-training-output-${OWNER}/backup/zeppelin/notebook"
if gsutil ls ${GCS_PATH} &>/dev/null
then
    gsutil -m rsync ${GCS_PATH} ${LOCAL_PATH}
fi
