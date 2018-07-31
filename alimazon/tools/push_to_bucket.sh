#!/bin/bash
# Util on top of gsutil to push files or folders to a bucket
# --------------------------------------------------------------

# Gather data and push it to the bucket and sort them on folders based on the number of users

##### Default parameters
bucket_url=""
resources=""
dataset_client_size=""

usage()
{
    echo "Push files into google bucket using gsutil"
    echo "Usage: $0 [parameters...] --bucket-url --resources-folder --client-size" >&2
    echo
    echo "   -b, --bucket-url         <bucket_url>          Google bucket url <gs://my-bucket>"
    echo "   -r, --resources-folder   <path_to_folder>      Path to resources folder where clients/ sell_orders/ and buy_orders/ exists"
    echo "   -s, --client-size        <number>              Number of clients on the dataset"
    echo "   -h, --help                                     Display help"
    echo
    exit 1
}

to_bucket()
{
    echo -n "Copying files... "
    echo
    gsutil -m cp $resources/clients/*.jsonl.gz $bucket_url/data-training-alimazon/$dataset_client_size/clients/
    gsutil -m cp $resources/buy-orders/*.jsonl.gz $bucket_url/data-training-alimazon/$dataset_client_size/buy-orders/
    gsutil -m cp $resources/sell-orders/*.jsonl.gz $bucket_url/data-training-alimazon/$dataset_client_size/sell-orders/
    echo "OK"
}


#### Main
while [ "$1" != "" ]; do
    case $1 in
        -b | --bucket-url )                 shift
                                bucket_url=$1
                                ;;
        -r | --resources-folder )           shift
                                resources=$1
                                ;;
        -s | --client-size )                shift
                                dataset_client_size=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$bucket_url" != "" ]; then
    if [ "$resources" != "" ]; then
        to_bucket
    else
        echo "Please specify a resources directory"
    fi
else
	echo "Please specify a valid bucket url"
fi
