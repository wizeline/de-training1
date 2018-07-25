#!/usr/bin/env python

from uuid import uuid4
from datetime import datetime, timedelta
import numpy as np
import random
import json
import click

from clients_service import ClientsService
from products_service import ProductsService
from random_util import _random_prices, _random_quantities, _to_price, _random_products
from date_util import sample_datetime_sequence, today_string, ensure_datetime, iso_string_to_date
import jsonl


clients = ClientsService()
products = ProductsService()

def generate_random_sell_orders(settings):
    end_date = iso_string_to_date(settings['end_date'])
    samplers = _create_data_samplers(settings)

    condition = 'registration_date >= "{}"'.format(iso_string_to_date(settings['start_date']))
    for client in clients.where(condition):
        client_id, client_signup_date = client
        client_profile = next(samplers['client_profile_sampler'])
        for timestamp in _client_purchase_dates(client_signup_date, end_date, client_profile):
            yield _random_sell_order(client_id, timestamp, samplers)


def _create_data_samplers(settings):
    return {
        'product_sampler': _random_products(),
        'client_profile_sampler': _random_client_profiles(settings['client_profiles']),
        'product_price_sampler': _random_prices(
            settings['min_product_price'],
            settings['max_product_price']),
        'product_quantity_sampler': _random_quantities(
            settings['min_product_quantity'],
            settings['max_product_quantity']),
    }


def _client_purchase_dates(start_date, end_date, profile):
    start_date = ensure_datetime(start_date)
    end_date = ensure_datetime(end_date)

    return sample_datetime_sequence(
        start_date,
        end=end_date,
        step=timedelta(days=profile['purchase_recurring_period_days']),
        sample_probability=profile['purchase_probability'])


def _random_sell_order(client_id, timestamp, samplers):
    product_price = next(samplers['product_price_sampler'])
    quantity = next(samplers['product_quantity_sampler'])
    product_id = next(samplers['product_sampler']).id
    return {
        'id': str(uuid4()),
        'client_id': client_id,
        'timestamp': timestamp.isoformat(),
        'product_id': product_id,
        'quantity': quantity,
        'total': _to_price(quantity * product_price)
    }



def _random_client_profiles(client_profiles):
    weights = list(map(lambda profile: profile['occurrence_probability'], client_profiles))
    while True:
        yield np.random.choice(client_profiles, p=weights)


@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option(
    '-c', '--conf-file',
    help="""
    JSON format Client purchase orders configuration file (e.g. sell_orders.conf). If it is not specified, default values will be used.
    """,
    type=str
)
def _smoke_test(conf_file='sell_orders_default.conf'):
    with open(conf_file) as json_conf_file:
        settings = json.load(json_conf_file)
    orders = generate_random_sell_orders(settings)

    def generate_suffix(index):
        return '_{0}_{1:05}'.format(today_string(), index)

    jsonl.write_to_files('./resources/sell-orders/part.jsonl.gz',
                         orders,
                         max_records_per_file=5000,
                         suffix_generator=generate_suffix)


if __name__ == '__main__':
    _smoke_test()
