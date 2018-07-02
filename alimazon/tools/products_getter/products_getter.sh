#!/bin/bash

# Get a list of product reviews from Amazon and extract just the product information.
# The dataset has been made available by Amazon for research and educational purposes only.
# https://s3.amazonaws.com/amazon-reviews-pds/tsv/index.txt

# The dataset is partitioned into compressed, tab-separated files grouped by category.
# Each file contains the following columns, in order:
#
# [1]  'marketplace',
# [2]  'customer_id',
# [3]  'review_id',
# [4]  'product_id',
# [5]  'product_parent',
# [6]  'product_title',
# [7]  'product_category',
# [8]  'star_rating',
# [9]  'helpful_votes',
# [10] 'total_votes',
# [11] 'vine',
# [12] 'verified_purchase',
# [13] 'review_headline',
# [14] 'review_body',
# [15] 'review_date'

SIMULTANEOUS_DOWNLOADS=5

download_and_reduce_all() {
    local urls_filename=$1
    local output_filename=$2

    download_all $urls_filename
    reduce_all $urls_filename $output_filename
}

download_all() {
    local urls_filename=$1

    echo "Fetching remote files in $urls_filename"
    echo "Using $SIMULTANEOUS_DOWNLOADS simultaneous downloads at most"

    parallel --progress --bar "-j${SIMULTANEOUS_DOWNLOADS}" curl {} -O --retry 5 < $urls_filename
}

select_unique_products() {
    awk -F"\t" '{ if (!seen[$4]) { printf "%s\t%s\t%s\n", $4, $6, $7; seen[$4]=1; } }' -
}
export -f select_unique_products

delete_duplicate_products() {
    awk -F"\t" '{ if (!seen[$1]) { printf "%s\t%s\t%s\n", $1, $2, $3; seen[$1]=1; } }' -
}

unzip_and_reduce() {
    local zipped_filename=$1
    gzip --decompress --to-stdout $zipped_filename \
        | select_unique_products
}
export -f unzip_and_reduce

reduce_all() {
    local sample_filename=$1
    local output_filename=$2

    local base_dirname=$(dirname $sample_filename)
    local suffix="${output_filename%%.*}_"

    echo "Processing downloaded zipped files in '$base_dirname' => $output_filename"

    ls $base_dirname/*.gz | parallel -j0 --bar --line-buffer unzip_and_reduce \
        | delete_duplicate_products \
        | pv --progress --timer --rate \
        | gzip \
        > $output_filename
}

shuffle_gzipped() {
    local input_filename=$1
    local output_filename=$2

    local header=`gzip -dc < $input_filename | head -n 1`

    echo "Shuffling zipped file: $input_filename"
    echo "header: $header"

    gzip --decompress --to-stdout $input_filename \
        | tail -n +2 \
        | { echo "$header"; gshuf; } \
        | gzip > $output_filename
}

partition () {
    local input_filename=$1
    local prefix="${input_filename%%.*}_"

    gzip --decompress --to-stdout $input_filename \
        | parallel --block 50M --header : --pipe "gzip > $prefix{#}.tsv.gz"
}

INPUT_FILE=$1
OUTPUT_FILE=$2

# reduce_all $INPUT_FILE $OUTPUT_FILE
# shuffle_gzipped $INPUT_FILE $OUTPUT_FILE
# partition $INPUT_FILE
