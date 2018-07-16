import random
import numpy as np
from products_service import ProductsService


def _random_products():
    products = ProductsService()
    while True:
        yield products.choose_random()


def _random_prices(min, max):
    assert min >= 0
    for number in _truncated_lognormal_sequence(min, max):
        yield _to_price(number)


def _to_price(number):
    return round(number, ndigits=2)


def _random_quantities(min, max):
    # TODO: replace with a power law distribution
    while True:
        yield int(random.uniform(min, max))


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
