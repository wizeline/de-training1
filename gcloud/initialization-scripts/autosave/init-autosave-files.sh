#!/bin/bash
set -exo pipefail
readonly ROLE="$(/usr/share/google/get_metadata_value attributes/dataproc-role)"

function main() {
  if [[ "${ROLE}" == 'Master' ]]; then
    BUCKET=`curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/backup_bucket" -H "Metadata-Flavor: Google"`
    LOCAL_PATH="/var/lib/zeppelin/notebook"
    GCS_PATH="gs://${BUCKET}/backup/zeppelin/notebook"
    if gsutil ls ${GCS_PATH} &>/dev/null
    then
        gsutil -m rsync -r ${GCS_PATH} ${LOCAL_PATH}
        chown zeppelin:zeppelin -R ${LOCAL_PATH}
    fi

    apt-get install -qq --yes --force-yes inotify-tools
    gsutil cp gs://de-training-config/zeppelin/autosave-zeppelin.service /etc/systemd/system
    gsutil cp gs://de-training-config/zeppelin/autosave-zeppelin.sh /opt
    systemctl daemon-reload
    systemctl start autosave-zeppelin.service
    systemctl enable autosave-zeppelin.service
    systemctl restart zeppelin.service
  fi
}

main
