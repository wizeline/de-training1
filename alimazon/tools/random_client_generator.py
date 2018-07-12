#!/usr/bin/env python
"""Generate random clients records"""
from bisect import bisect
from datetime import datetime, timedelta
from itertools import accumulate
from random import random
from uuid import uuid4
import math

import jsonl

_GENDERS = ('male', 'female', None)

_DEFAULT_SAMPLE_SIZE = 5*10**4
_DEFAULT_START_DATE = datetime(2017, 1, 1)
_DEFAULT_PERIOD_IN_YEARS = 3
_DEFAULT_NAMES_FILE = './resources/names.txt'
_DEFAULT_SURNAMES_FILE = './resources/surnames.txt'
_DEFAULT_COUNTRY_CODES_FILE = '../docs/resources/country_codes.csv'
_DEFAULT_ROWS_PER_FILE = 5000
_DEFAULT_OUTPUT_FOLDER = './resources/clients'


def _weights(domain, default_weight='auto', **custom_weights):
    if isinstance(default_weight, str) and default_weight.lower() == 'auto':
        default_weight = (1.0-sum(custom_weights.values())) / (len(domain)-len(custom_weights))
    weights = [default_weight] * len(domain)
    for key, weight in custom_weights.items():
        if key.lower() == '_none':
            key = None
        try:
            weights[domain.index(key)] = weight
        except ValueError:
            raise ValueError('{} not found in the given domain.'.format(key))
    return tuple(weights)


def _sampler(choices, weights):
    cumulative_distribution = list(accumulate(weights))
    while True:
        weight = random() * cumulative_distribution[-1]
        yield choices[bisect(cumulative_distribution, weight)]


def _parse_args():
    return {
        'sample_size': _DEFAULT_SAMPLE_SIZE,
        'start': _DEFAULT_START_DATE,
        'period': _DEFAULT_PERIOD_IN_YEARS * 365,
        'names_filename': _DEFAULT_NAMES_FILE,
        'surnames_filename': _DEFAULT_SURNAMES_FILE,
        'codes_filename': _DEFAULT_COUNTRY_CODES_FILE,
        'max_rows': _DEFAULT_ROWS_PER_FILE,
        'output_folder': _DEFAULT_OUTPUT_FOLDER,
    }


def _today_string():
    return datetime.today().strftime('%Y%m%dT%H%M%S')


def samples(samplers, context):
    for _ in range(context['max_rows']):
        yield {
            'id': str(uuid4()),
            'name': '{} {}'.format(next(samplers['names_sampler']),
                                   next(samplers['surnames_sampler'])),
            'gender': next(samplers['gender_sampler']),
            'country': next(samplers['codes_sampler']),
            'registration_date': (
                context['start'] + timedelta(context['period'] * random())).isoformat()
        }


def _main():
    args = _parse_args()

    with open(args['names_filename']) as names_file, \
            open(args['surnames_filename']) as surnames_file, \
            open(args['codes_filename']) as countries_file:
        names = [n.strip() for n in names_file.readlines()]
        surnames = [s.strip() for s in surnames_file.readlines()]
        codes = [c.strip().split('|')[0] for c in countries_file][1:]
        codes.append(None)

    samplers = {
        'names_sampler': _sampler(names, _weights(names)),
        'surnames_sampler': _sampler(surnames, _weights(surnames)),
        'gender_sampler': _sampler(_GENDERS, _weights(_GENDERS, _none=0.4)),
        'codes_sampler': _sampler(codes, _weights(codes, _none=0.3))
    }
    files_count = math.ceil(args['sample_size'] / args['max_rows'])
    for idx in range(files_count):
        rows = min(args['sample_size'] - args['max_rows'] * idx,
                   args['max_rows'])
        filename = '{}/{}_client_{:0>5}.jsonl.gz'.format(
            args['output_folder'],
            _today_string(),
            idx)
        jsonl.write_to_file(filename, samples(samplers, args), batch_size=rows)

if __name__ == '__main__':
    _main()
