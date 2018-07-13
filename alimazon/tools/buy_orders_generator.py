#!/usr/bin/env python

from uuid import uuid4
from datetime import datetime, timedelta
import dateutil.parser as date_parser
import numpy as np
import random

from products_service import ProductsService
from date_util import sample_datetime_sequence, today_string
import jsonl

products = ProductsService()

def generate_random_buy_orders(settings):
    n_orders = settings['buy_orders_count']
    end_date = settings['end_date']
    start_date = settings['start_date']
    samplers = _create_data_samplers(settings)
    supplier_profile = next(samplers['supplier_profile_sampler'])

    for _ in range(n_orders):
        for timestamp in _create_purchase_dates(start_date, end_date, supplier_profile):
            yield _random_buy_order(timestamp, samplers)


def _create_data_samplers(settings):
    return {
        'product_sampler': _random_products(),
        'supplier_profile_sampler': _random_supplier_profiles(settings['supplier_profiles']),
        'product_price_sampler': _random_prices(
            settings['min_product_price'],
            settings['max_product_price']),
        'product_quantity_sampler': _random_quantities(
            settings['min_product_quantity'],
            settings['max_product_quantity']),
    }


def _random_products():
    while True:
        yield products.choose_random()


def _random_supplier_profiles(supplier_profiles):
    weights = list(map(lambda profile: profile['occurrence_probability'], supplier_profiles))
    while True:
        yield np.random.choice(supplier_profiles, p=weights)


def _random_prices(min, max):
    assert min >= 0
    for number in _truncated_lognormal_sequence(min, max):
        yield _to_price(number)


def _random_quantities(min, max):
    # TODO: replace with a power law distribution
    while True:
        yield int(random.uniform(min, max))


def _create_purchase_dates(start_date, end_date, profile):
    start_date = _ensure_datetime(start_date)
    end_date = _ensure_datetime(end_date)

    return sample_datetime_sequence(
        start_date,
        end=end_date,
        step=profile['purchase_recurring_period'],
        sample_probability=profile['purchase_probability'])


def _ensure_datetime(date):
    if type(date) != datetime:
        date = date_parser.parse(date)
    return date


def _random_buy_order(timestamp, samplers):
    product_price = next(samplers['product_price_sampler'])
    quantity = next(samplers['product_quantity_sampler'])
    product_id = next(samplers['product_sampler']).id
    return {
        'id': str(uuid4()),
        'timestamp': timestamp.isoformat(),
        'product_id': product_id,
        'quantity': quantity,
        'total': _to_price(quantity * product_price)
    }


def _to_price(number):
    return round(number, ndigits=2)


# TODO: this is a (very) poor man's method of generating a truncated lognormal distribution
#       DO NOT use it for something serious
def _truncated_lognormal_sequence(lower, upper):
    _DEFAULT_BATCH_SIZE = 1000
    if lower > upper:
        raise ValueError('condition [lower >= upper] is not satisfied')

    while True:
        draws = list(np.random.lognormal(mean=3.0, sigma=1.0, size=_DEFAULT_BATCH_SIZE))
        while draws:
            number = draws.pop()
            if lower <= number <= upper:
                yield number


def _smoke_test():
    today = datetime.today()
    one_month = today + timedelta(weeks=4)
    settings = {
        'buy_orders_count': 10000,
        'start_date': today,
        'end_date': one_month,
        'min_product_price': 1.0,
        'max_product_price': 10000,
        'min_product_quantity': 1,
        'max_product_quantity': 100,
        'supplier_profiles': [
            {
                'type': 'approved',
                'occurrence_probability': 0.15,
                'purchase_recurring_period': timedelta(days=6),
                'purchase_probability': 0.65,

            },
            {
                'type': 'prefered',
                'occurrence_probability': 0.65,
                'purchase_recurring_period': timedelta(days=2),
                'purchase_probability': 0.85
            },
            {
                'type': 'strategic',
                'occurrence_probability': 0.20,
                'purchase_recurring_period': timedelta(days=5),
                'purchase_probability': 0.70
            }
        ],
    }
    orders = generate_random_buy_orders(settings)

    def generate_suffix(index):
        return '_{0}_{1:05}'.format(today_string(), index)

    jsonl.write_to_files('./resources/buy-orders/part.jsonl.gz',
                         orders,
                         max_records_per_file=5000,
                         suffix_generator=generate_suffix)


if __name__ == '__main__':
    _smoke_test()
