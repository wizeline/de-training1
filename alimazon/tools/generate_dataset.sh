#!/bin/bash
# Alimazon dataset generator
# --------------------------------------------------------------

##### Default parameters
client_settings=""
product_settings=""
buy_settings=""
sell_settings=""
bucket_url=""
client_count=""

##### Functions
usage()
{
    echo "Alimazon dataset generator"
    echo "Usage: $0 [parameters...] --client-settings --client-purchase-orders --stock-purchase-orders " >&2
    echo
    echo "   -c, --client-settings          <path_to_file>        JSON settings file for Clients dataset generator"
    echo "   -b, --client-purchase-orders   <path_to_file>        JSON settings file for Client purchase orders dataset generator"
    echo "   -s, --stock-purchase-orders    <path_to_file>        JSON settings file for Stock purchase orders dataset generator"
    echo "   -u, --bucket-url               <gs_bucket_url>       Valid Google Storage bucket URL"
    echo "   -h, --help                                           Display help"
    echo
    exit 1
}

generate_clients()
{
    echo -n "Generating clients... "
    python random_client_generator.py -c $client_settings
    echo "OK"
    python jsonl_to_sqlite.py "resources/clients/*.jsonl.gz" --output-filepath="resources/clients/client.sqlite" --columns="id,registration_date"
}

generate_buy_orders()
{
    echo -n "Generating buy orders... "
    python buy_orders_generator.py -c $buy_settings
    echo "OK"
}

generate_sell_orders()
{
    echo -n "Generating sell orders... "
    python sell_orders_generator.py -c $sell_settings
    echo "OK"
}

push_to_bucket()
{
    temp=`cat $client_settings | grep -o -E "\"sample_size\": [0-9]+" | awk -F "\: " '{print $2}'`
    client_count=${temp##*|}
    ./push_to_bucket.sh -b $bucket_url -r resources -s $client_count
}

#### Main
while [ "$1" != "" ]; do
    case $1 in
        -c | --client-settings )        shift
                                client_settings=$1
                                ;;
        -b | --buy-settings )           shift
                                buy_settings=$1
                                ;;
        -s | --sell-settings )          shift
                                sell_settings=$1
                                ;;
        -u | --bucket-url  )            shift
                                bucket_url=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$client_settings" != "" ]; then
    generate_clients
    if [ "$buy_settings" != "" ]; then
        generate_buy_orders
        if [ "$sell_settings" != "" ]; then
            generate_sell_orders
            echo "Dataset generation completed successfully"
            if [ "$bucket_url" != "" ]; then
                push_to_bucket
            fi
        fi
    else
        echo "Stock purchase settings were not specified, the complete dataset will not be generated"
    fi
else
	echo "Client dataset settings was not specified, the complete dataset will not be generated"
fi
