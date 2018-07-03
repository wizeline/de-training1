#!/bin/bash

TARGET_URLS='subset_amazon_reviews_dataset_urls.txt'
DOWNLOADED_FILES='downloaded_files.txt'
TARGET_FILES='target_files.txt'
REMAINING_FILES='remaining_files.txt'
REMAINING_DOWNLOADS='remaining_downloads.txt'

ls .cache/*.gz | xargs -n1 basename > $DOWNLOADED_FILES

cat $TARGET_URLS | awk -F / '{print $NF}' > $TARGET_FILES

diff --new-line-format="" --unchanged-line-format="" <(sort $TARGET_FILES) <(sort $DOWNLOADED_FILES) > $REMAINING_FILES

awk '{ printf "https://s3.amazonaws.com/amazon-reviews-pds/tsv/%s\n", $1 }' \
    $REMAINING_FILES | tee $REMAINING_DOWNLOADS

rm $TARGET_FILES $REMAINING_FILES $DOWNLOADED_FILES

echo
echo "$REMAINING_DOWNLOADS has been updated." \
     $(cat $REMAINING_DOWNLOADS | wc -l) "files remain to be downloaded"
