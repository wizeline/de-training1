#!/usr/bin/env python
"""Generate random clients records"""
from bisect import bisect
from datetime import datetime, timedelta
from itertools import accumulate
from random import random
from uuid import uuid4
import gzip
import json


_GENDERS = ('male', 'female', None)

_DEFAULT_SAMPLE_SIZE = 5*10**4
_DEFAULT_START_DATE = datetime(2017, 1, 1)
_DEFAULT_PERIOD = 3  # years
_DEFAULT_NAMES_FILE = './resources/names.txt'
_DEFAULT_SURNAMES_FILE = './resources/surnames.txt'
_DEFAULT_CODES_FILE = '../docs/resources/country_codes.csv'
_DEFAULT_ROWS_PER_FILE = 10000
_DEFAULT_OUTPUT_FOLDER = './resources/clients'


def _weights(domain, default_weight='auto', **kwargs):
    if isinstance(default_weight, str) and default_weight.lower() == 'auto':
        default_weight = (1.0-sum(kwargs.values())) / (len(domain)-len(kwargs))
    weights = [default_weight] * len(domain)
    for key, val in kwargs.items():
        if key.lower() == '_none':
            key = None
        try:
            weights[domain.index(key)] = val
        except ValueError:
            raise ValueError('{} not found in the given domain.'.format(key))
    return tuple(weights)


def _sampler(choices, weights):
    cumdist = list(accumulate(weights))
    while True:
        weight = random() * cumdist[-1]
        yield choices[bisect(cumdist, weight)]


def _parse_args():
    return {
        'sample_size': _DEFAULT_SAMPLE_SIZE,
        'start': _DEFAULT_START_DATE,
        'period': _DEFAULT_PERIOD * 365,
        'names_filename': _DEFAULT_NAMES_FILE,
        'surnames_filename': _DEFAULT_SURNAMES_FILE,
        'codes_filename': _DEFAULT_CODES_FILE,
        'max_rows': _DEFAULT_ROWS_PER_FILE,
        'output_folder': _DEFAULT_OUTPUT_FOLDER,
    }


def _today_string():
    return datetime.today().strftime('%Y%m%dT%H%M%S')


def _main():
    args = _parse_args()

    with open(args['names_filename']) as names_file, \
            open(args['surnames_filename']) as surnames_file, \
            open(args['codes_filename']) as countries_file:
        names = [n.strip() for n in names_file.readlines()]
        surnames = [s.strip() for s in surnames_file.readlines()]
        codes = [c.strip().split('|')[0] for c in countries_file][1:]
        codes.append(None)

    names_sampler = _sampler(names, _weights(names))
    surnames_sampler = _sampler(surnames, _weights(surnames))
    gender_sampler = _sampler(_GENDERS, _weights(_GENDERS, _none=0.4))
    codes_sampler = _sampler(codes, _weights(codes, _none=0.3))

    for idx in range((args['sample_size'] + 1) // args['max_rows']):
        rows = min(args['sample_size'] - args['max_rows'] * (idx + 1),
                   args['max_rows'])
        filename = '{}/{}_client_{:0>5}.jsonl.gz'.format(args['output_folder'],
                                                         _today_string(),
                                                         idx)
        with gzip.open(filename, 'wt') as output_file:
            output_file.write('\n'.join(json.dumps({
                'id': str(uuid4()),
                'name': '{} {}'.format(next(names_sampler),
                                       next(surnames_sampler)),
                'gender': next(gender_sampler),
                'country': next(codes_sampler),
                'registration_date': (args['start'] +
                                      timedelta(args['period'] *
                                                random())).isoformat()
            }) for _ in range(rows)))


if __name__ == '__main__':
    _main()
